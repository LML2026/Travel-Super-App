import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/models/booking.dart';
import 'package:travel_super_app/features/authentication/domain/entities/auth_user.dart';
import 'package:travel_super_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:travel_super_app/features/discovery/data/travel_discovery_service.dart';
import 'package:travel_super_app/features/discovery/domain/travel_discovery_models.dart';
import 'package:travel_super_app/features/discovery/presentation/providers/travel_discovery_provider.dart';
import 'package:travel_super_app/features/saved_items/data/saved_items_repository.dart';
import 'package:travel_super_app/features/saved_items/presentation/providers/saved_items_provider.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_activity.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_activity_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_activity_provider.dart';

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

    test('confirmed flight booking is saved against selected trip', () async {
      final savedBookings = <Booking>[];
      final container = ProviderContainer(
        overrides: [
          immediateCurrentUserProvider.overrideWithValue(
            const AuthUser(
              uid: 'user-1',
              email: 'traveller@example.com',
              emailVerified: true,
            ),
          ),
          travelDiscoveryBookingSaverProvider.overrideWithValue(
            (booking) async => savedBookings.add(booking),
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

      final booking = await controller.confirmBooking(
        _result(DiscoveryCategory.flights),
      );

      expect(savedBookings, hasLength(1));
      expect(booking.tripId, 'trip-1');
      expect(booking.userId, 'user-1');
      expect(booking.type, BookingType.flight);
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.metadata['provider'], 'ITAREVO Demo Flights');
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
