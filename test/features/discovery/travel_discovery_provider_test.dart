import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/discovery/data/travel_discovery_service.dart';
import 'package:travel_super_app/features/discovery/domain/travel_discovery_models.dart';
import 'package:travel_super_app/features/discovery/presentation/providers/travel_discovery_provider.dart';
import 'package:travel_super_app/features/saved_items/data/saved_items_repository.dart';
import 'package:travel_super_app/features/saved_items/presentation/providers/saved_items_provider.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_activity.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_activity_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_activity_provider.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_booking_link_provider.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';
import 'package:travel_super_app/features/trips/services/trip_booking_link_service.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';

void main() {
  group('TravelDiscoveryController', () {
    test('search returns sorted unified demo results and preserves selections',
        () async {
      final container = ProviderContainer(
        overrides: [
          travelDiscoveryServiceProvider.overrideWithValue(
            const DemoTravelDiscoveryService(),
          ),
          savedItemsRepositoryProvider.overrideWithValue(
            MemorySavedItemsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(travelDiscoveryControllerProvider.future);
      final controller =
          container.read(travelDiscoveryControllerProvider.notifier);

      controller.selectTrip('trip-1');
      await controller.search(_query());
      await controller.toggleSave('demo-transport-private');
      controller.toggleCompare('demo-flight-direct');

      final state =
          container.read(travelDiscoveryControllerProvider).requireValue;
      final categories = state.results.map((result) => result.category).toSet();

      expect(categories, containsAll(DiscoveryCategory.values));
      expect(state.selectedTripId, 'trip-1');
      expect(state.savedIds, contains('demo-transport-private'));
      expect(state.compareIds, contains('demo-flight-direct'));
      expect(state.results.first.price,
          lessThanOrEqualTo(state.results.last.price));
    });

    test('demo bookable result links as a trip plan, not a confirmed booking',
        () async {
      final savedFlights = <String>[];
      Trip? updatedTrip;
      final trip = _trip();
      final container = ProviderContainer(
        overrides: [
          selectedTripProvider('trip-1').overrideWith((ref) async => trip),
          tripBookingLinkServiceProvider.overrideWithValue(
            TripBookingLinkService(
              tripRepository: _TripRepository(
                onUpdate: (value) => updatedTrip = value,
              ),
              flightSavedLookup: (_) async => false,
              flightSaver: (flight) async => savedFlights.add(flight.id),
            ),
          ),
          savedItemsRepositoryProvider.overrideWithValue(
            MemorySavedItemsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(travelDiscoveryControllerProvider.future);
      final controller =
          container.read(travelDiscoveryControllerProvider.notifier);
      controller.selectTrip('trip-1');

      final link = await controller.linkBookableResult(
        _result(DiscoveryCategory.flights),
      );

      expect(link.status, TripBookingLinkStatus.linked);
      expect(savedFlights, ['result-flights']);
      expect(updatedTrip?.selectedFlightId, 'result-flights');
    });

    test('restaurant result is added through trip activity architecture',
        () async {
      final repository = _MemoryTripActivityRepository();
      final container = ProviderContainer(
        overrides: [
          tripActivityRepositoryProvider.overrideWithValue(repository),
          savedItemsRepositoryProvider.overrideWithValue(
            MemorySavedItemsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(travelDiscoveryControllerProvider.future);
      final controller =
          container.read(travelDiscoveryControllerProvider.notifier);
      controller.selectTrip('trip-1');

      await controller.addToTrip(_result(DiscoveryCategory.restaurants));

      expect(repository.addedActivities, hasLength(1));
      final activity = repository.addedActivities.single;
      expect(activity.tripId, 'trip-1');
      expect(activity.title, 'Local table in Paris');
      expect(activity.status, 'Restaurant planned');
      expect(activity.cost, 64);
    });
  });
}

Trip _trip() {
  return Trip(
    id: 'trip-1',
    title: 'Paris',
    destination: 'Paris',
    startDate: DateTime(2026, 9, 1),
    endDate: DateTime(2026, 9, 4),
    budget: 1200,
  );
}

TravelDiscoveryQuery _query() {
  return TravelDiscoveryQuery(
    destination: 'Paris',
    origin: 'LHR',
    startDate: DateTime(2026, 9, 1),
    endDate: DateTime(2026, 9, 4),
    travellers: 2,
    rooms: 1,
  );
}

TravelDiscoveryResult _result(DiscoveryCategory category) {
  return TravelDiscoveryResult(
    id: 'result-${category.name}',
    category: category,
    title: category == DiscoveryCategory.restaurants
        ? 'Local table in Paris'
        : 'Direct flight to Paris',
    subtitle: category == DiscoveryCategory.restaurants
        ? 'Local cuisine'
        : 'LHR to Paris',
    provider: category == DiscoveryCategory.restaurants
        ? 'ITAREVO Demo Restaurants'
        : 'ITAREVO Demo Flights',
    location: 'Paris',
    startTime: DateTime(2026, 9, 1, 12),
    endTime: DateTime(2026, 9, 1, 14),
    duration: '2h',
    price: category == DiscoveryCategory.restaurants ? 64 : 220,
    currency: 'GBP',
    rating: 4.6,
    details: 'Deterministic demo result.',
  );
}

class _MemoryTripActivityRepository implements TripActivityRepository {
  final addedActivities = <TripActivity>[];

  @override
  Future<void> addActivity(TripActivity activity) async {
    addedActivities.add(activity);
  }

  @override
  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) async {}

  @override
  Future<void> updateActivity(TripActivity activity) async {}

  @override
  Stream<List<TripActivity>> watchActivities(String tripId) {
    return Stream.value(addedActivities);
  }
}

class _TripRepository implements TripRepository {
  _TripRepository({this.onUpdate});

  final void Function(Trip trip)? onUpdate;

  @override
  Future<void> createTrip(Trip trip) async {}

  @override
  Future<void> deleteTrip(String id) async {}

  @override
  Future<Trip?> get(String id) async => _trip();

  @override
  Future<List<Trip>> getAll() async => [_trip()];

  @override
  Future<void> updateTrip(Trip trip) async => onUpdate?.call(trip);

  @override
  Stream<List<Trip>> watchTrips() => Stream.value([_trip()]);
}
