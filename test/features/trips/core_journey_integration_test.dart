import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/models/booking.dart';
import 'package:travel_super_app/features/ai_planner/domain/ai_planner_models.dart';
import 'package:travel_super_app/features/ai_planner/domain/ai_planner_repository.dart';
import 'package:travel_super_app/features/ai_planner/presentation/providers/ai_planner_provider.dart';
import 'package:travel_super_app/features/ai_planner/services/ai_planner_service.dart';
import 'package:travel_super_app/features/discovery/data/travel_discovery_service.dart';
import 'package:travel_super_app/features/discovery/domain/travel_discovery_models.dart';
import 'package:travel_super_app/features/flights/models/saved_flight.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_activity.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_activity_repository.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/domain/services/trip_event_composer.dart';
import 'package:travel_super_app/features/trips/services/trip_booking_link_service.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_activity_provider.dart';

void main() {
  testWidgets('core organizer journey survives reload', (tester) async {
    final trips = _TripsRepository();
    final activities = _ActivitiesRepository();
    final planner = _PlannerRepository();
    final savedFlights = <SavedFlight>[];

    await trips.createTrip(_trip());
    final reopenedTrip = await trips.get('trip-journey');
    expect(reopenedTrip, isNotNull);

    final discovery = await const DemoTravelDiscoveryService().search(
      _query(),
    );
    final flightResult = discovery.firstWhere(
      (result) => result.category == DiscoveryCategory.flights,
    );
    final linkService = TripBookingLinkService(
      tripRepository: trips,
      flightSavedLookup: (id) async =>
          savedFlights.any((flight) => flight.flightId == id),
      flightSaver: (flight) async {
        savedFlights.add(
          SavedFlight(
            id: flight.id,
            flightId: flight.id,
            airline: flight.airline,
            airlineLogo: flight.airlineLogo,
            flightNumber: flight.flightNumber,
            origin: flight.origin,
            destination: flight.destination,
            departureAt: flight.departureAt,
            arrivalAt: flight.arrivalAt,
            duration: flight.duration,
            stops: flight.stops,
            amount: flight.amount,
            currency: flight.currency,
            cabinClass: flight.cabinClass,
            savedAt: DateTime(2026, 8, 1),
          ),
        );
      },
    );
    final link = await linkService.linkDiscoveryResult(
      trip: reopenedTrip!,
      result: flightResult,
    );
    expect(link.status, TripBookingLinkStatus.linked);
    expect(
        (await trips.get('trip-journey'))!.selectedFlightId, flightResult.id);
    expect(savedFlights, hasLength(1));

    final aiController = AiPlannerController(
      tripId: 'trip-journey',
      service: const LocalAiPlannerService(),
      repository: planner,
      activityActions: TripActivityActions(activities),
    );
    await aiController.generate(
      AiPlannerContext(
        trip: reopenedTrip,
        activities: const [],
        bookings: const <Booking>[],
        expenses: const [],
        preferences: const AiPlannerPreferences(
          interests: {'culture'},
          pace: AiPlannerPace.relaxed,
        ),
      ),
    );
    final suggestion = aiController.state.value!.days.first.suggestions.first;
    await aiController.acceptSuggestion(suggestion);

    final composed = const TripEventComposer().compose(
      trip: reopenedTrip,
      linkedFlight: savedFlights.single,
      activities: activities.added,
    );
    expect(composed.any((event) => event.source == 'linkedFlight'), isTrue);
    expect(composed.any((event) => event.title == suggestion.title), isTrue);
    expect(composed.where((event) => event.title == suggestion.title),
        hasLength(1));
    expect(planner.getPlanHistory('trip-journey'), completion(isNotEmpty));

    final reloadedTrip = await trips.get('trip-journey');
    final restoredPlan =
        (await planner.getPlanHistory(reloadedTrip!.id)).single;
    final reloadedEvents = const TripEventComposer().compose(
      trip: reloadedTrip,
      linkedFlight: savedFlights.single,
      activities: activities.added,
    );
    expect(reloadedTrip.selectedFlightId, flightResult.id);
    expect(restoredPlan.preferences.pace, AiPlannerPace.relaxed);
    expect(
        reloadedEvents.any((event) => event.title == suggestion.title), isTrue);
  });
}

Trip _trip() => Trip(
      id: 'trip-journey',
      title: 'Paris Journey',
      destination: 'Paris',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 3),
      budget: 900,
      travellers: 2,
    );

TravelDiscoveryQuery _query() => TravelDiscoveryQuery(
      destination: 'Paris',
      origin: 'LHR',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 3),
      travellers: 2,
    );

class _TripsRepository implements TripRepository {
  final values = <String, Trip>{};

  @override
  Future<void> createTrip(Trip trip) async => values[trip.id] = trip;

  @override
  Future<void> deleteTrip(String id) async => values.remove(id);

  @override
  Future<Trip?> get(String id) async => values[id];

  @override
  Future<List<Trip>> getAll() async => values.values.toList();

  @override
  Future<void> updateTrip(Trip trip) async => values[trip.id] = trip;

  @override
  Stream<List<Trip>> watchTrips() => Stream.value(values.values.toList());
}

class _ActivitiesRepository implements TripActivityRepository {
  final added = <TripActivity>[];

  @override
  Future<void> addActivity(TripActivity activity) async => added.add(activity);

  @override
  Future<void> deleteActivity(
      {required String tripId, required String activityId}) async {}

  @override
  Future<void> updateActivity(TripActivity activity) async {}

  @override
  Stream<List<TripActivity>> watchActivities(String tripId) =>
      Stream.value(added.where((item) => item.tripId == tripId).toList());
}

class _PlannerRepository
    implements AiPlannerRepository, AiPlannerPreferencesRepository {
  final plans = <String, AiPlannerPlan>{};
  AiPlannerPreferences? preferences;

  @override
  Future<List<AiPlannerPlan>> getPlanHistory(String tripId) async =>
      plans.values
          .where((plan) => plan.tripId == tripId)
          .toList(growable: false);

  @override
  Future<void> savePlan(AiPlannerPlan plan) async => plans[plan.id] = plan;

  @override
  Stream<List<AiPlannerPlan>> watchPlanHistory(String tripId) =>
      Stream.fromFuture(getPlanHistory(tripId));

  @override
  Future<AiPlannerPreferences?> getPreferences(String tripId) async =>
      preferences;

  @override
  Future<void> savePreferences(
    String tripId,
    AiPlannerPreferences value,
  ) async =>
      preferences = value;
}
