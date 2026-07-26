import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../flights/providers/flight_provider.dart';
import '../../hotels/providers/hotel_experience_provider.dart';
import '../../hotels/providers/hotel_provider.dart';
import '../../trips/domain/entities/trip.dart';
import '../../trips/providers/trip_provider.dart';
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

  Future<void> sendPrompt(String prompt) async {
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
      final relevantTrip = _findRelevantTrip(trimmed, trips);

      WeatherData? weather;
      List<String> nearbyAttractions = const [];

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
      }

      final response =
          await _ref.read(aiAssistantRepositoryProvider).generateResponse(
                trimmed,
                trips: trips,
                flights: flights,
                hotels: hotels,
                weather: weather,
                nearbyAttractions: nearbyAttractions,
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
