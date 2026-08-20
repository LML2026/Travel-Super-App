import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/booking.dart';
import '../../flights/providers/flight_provider.dart';
import '../../hotels/providers/hotel_experience_provider.dart';
import '../../hotels/providers/hotel_provider.dart';
import '../../trips/domain/entities/trip.dart';
import '../../trips/domain/entities/trip_activity.dart';
import '../../trips/presentation/providers/trip_activity_provider.dart';
import '../../trips/presentation/providers/trip_bookings_provider.dart';
import '../../trips/presentation/providers/trip_provider.dart';
import '../../trips/domain/services/trip_event_composer.dart';
import '../../expenses/presentation/providers/expense_provider.dart';
import '../../expenses/domain/entities/expense.dart';
import '../../trip_readiness/presentation/providers/trip_readiness_provider.dart';
import '../../saved_items/presentation/providers/saved_items_provider.dart';
import '../../saved_items/domain/saved_item.dart';
import '../domain/ai_travel_context.dart';
import '../../weather/models/weather_data.dart';
import '../../weather/providers/weather_provider.dart';
import '../models/assistant_message.dart';
import '../repositories/ai_assistant_repository.dart';
import '../services/ai_assistant_service.dart';

final aiAssistantServiceProvider = Provider<AiAssistantService>(
  (ref) => AiAssistantService(),
);

final aiAssistantRepositoryProvider = Provider<AiAssistantRepository>(
  (ref) => AiAssistantRepository(ref.watch(aiAssistantServiceProvider)),
);

final aiAssistantLoadingProvider = StateProvider<bool>((ref) => false);

final aiAssistantMessagesProvider =
    StateNotifierProvider<AiAssistantNotifier, List<AssistantMessage>>(
  (ref) => AiAssistantNotifier(ref),
);

class AiAssistantNotifier extends StateNotifier<List<AssistantMessage>> {
  AiAssistantNotifier(this._ref)
      : super([
          AssistantMessage(
            id: const Uuid().v4(),
            text:
                'Ask me about destination ideas, budgets, or how to structure a trip.',
            isUser: false,
            createdAt: DateTime.now(),
          ),
        ]);

  final Ref _ref;

  Future<void> sendPrompt(String prompt, {Trip? activeTrip}) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) {
      return;
    }

    state = [
      ...state,
      AssistantMessage(
        id: const Uuid().v4(),
        text: trimmed,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    ];

    _ref.read(aiAssistantLoadingProvider.notifier).state = true;
    try {
      final trips = await _ref.read(tripsProvider.future);
      final flights = await _ref.read(savedFlightsProvider.future);
      final hotels = await _ref.read(savedHotelsProvider.future);
      final relevantTrip = activeTrip ?? _findRelevantTrip(trimmed, trips);

      WeatherData? weather;
      List<String> nearbyAttractions = const [];
      AiTravelContext? travelContext;

      if (relevantTrip != null) {
        if (relevantTrip.weatherSnapshot != null) {
          weather = WeatherData.fromJson(relevantTrip.weatherSnapshot!);
        } else {
          try {
            weather = await _ref
                .read(weatherProvider(relevantTrip.destination).future);
          } catch (_) {
            weather = null;
          }
        }

        try {
          final nearby = await _ref
              .read(nearbyBundleProvider(relevantTrip.destination).future);
          nearbyAttractions =
              nearby.attractions.map((place) => place.name).toList();
        } catch (_) {
          nearbyAttractions = const [];
        }

        final activities = await _ref
            .read(tripActivitiesProvider(relevantTrip.id).future)
            .catchError((_) => const <TripActivity>[]);
        final bookings = await _ref
            .read(tripBookingsProvider(relevantTrip.id).future)
            .catchError((_) => const <Booking>[]);
        final expenses = await _ref
            .read(tripExpensesProvider(relevantTrip.id).future)
            .catchError((_) => const <Expense>[]);
        final savedItems = await _ref
            .read(savedItemsControllerProvider.future)
            .catchError((_) => const <SavedItem>[]);
        final readiness =
            _ref.read(tripReadinessSummaryProvider(relevantTrip.id));
        final sharedEvents = const TripEventComposer().compose(
          trip: relevantTrip,
          bookings: bookings,
          activities: activities,
          reminders: readiness.reminders,
          includeReadiness: true,
        );
        travelContext = AiTravelContext.fromTripData(
          trip: relevantTrip,
          activities: activities,
          bookings: bookings,
          expenses: expenses,
          eventSummaries: sharedEvents
              .map((event) => '${event.title} at ${event.startTime}')
              .toList(growable: false),
          savedPlaces: savedItems
              .where((item) => item.isTripActivity)
              .map((item) => item.title)
              .toList(growable: false),
          weatherSummary: weather == null
              ? null
              : '${weather.description}, ${weather.tempC.toStringAsFixed(0)}°C',
          readinessSummary:
              '${readiness.completedCount}/${readiness.totalCount} tasks complete',
        );
      }

      final response =
          await _ref.read(aiAssistantRepositoryProvider).generateResponse(
                trimmed,
                trips: trips,
                flights: flights,
                hotels: hotels,
                weather: weather,
                nearbyAttractions: nearbyAttractions,
                travelContext: travelContext,
              );
      state = [
        ...state,
        AssistantMessage(
          id: const Uuid().v4(),
          text: response,
          isUser: false,
          createdAt: DateTime.now(),
        ),
      ];
    } finally {
      _ref.read(aiAssistantLoadingProvider.notifier).state = false;
    }
  }

  Trip? _findRelevantTrip(String prompt, List<Trip> trips) {
    if (trips.isEmpty) {
      return null;
    }

    final match = RegExp(r'to\s+([A-Z][a-zA-Z]+(?:\s+[A-Z][a-zA-Z]+)*)')
        .firstMatch(prompt);
    final destination = match?.group(1)?.toLowerCase();

    if (destination == null) {
      return trips.first;
    }

    for (final trip in trips) {
      if (trip.destination.toLowerCase().contains(destination)) {
        return trip;
      }
    }

    return trips.first;
  }
}
