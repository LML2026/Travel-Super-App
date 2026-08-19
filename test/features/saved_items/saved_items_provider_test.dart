import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/discovery/domain/travel_discovery_models.dart';
import 'package:travel_super_app/features/saved_items/data/saved_items_repository.dart';
import 'package:travel_super_app/features/saved_items/domain/saved_item.dart';
import 'package:travel_super_app/features/saved_items/presentation/providers/saved_items_provider.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_activity.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_activity_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_activity_provider.dart';

void main() {
  group('Saved items', () {
    test('persists discovery saves and removals', () async {
      final repository = MemorySavedItemsRepository();
      final container = ProviderContainer(
        overrides: [
          savedItemsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(savedItemsControllerProvider.future);
      await container
          .read(savedItemsControllerProvider.notifier)
          .saveDiscoveryResult(_restaurantResult());

      var items = await repository.load();
      expect(items, hasLength(1));
      expect(items.single.category, SavedItemCategory.restaurant);
      expect(items.single.title, 'Canal-side dinner');

      await container
          .read(savedItemsControllerProvider.notifier)
          .remove('demo-restaurant');

      items = await repository.load();
      expect(items, isEmpty);
    });

    test('adds saved restaurant to trip through activity architecture',
        () async {
      final activityRepository = _MemoryTripActivityRepository();
      final container = ProviderContainer(
        overrides: [
          savedItemsRepositoryProvider.overrideWithValue(
            MemorySavedItemsRepository(),
          ),
          tripActivityRepositoryProvider.overrideWithValue(activityRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(savedItemsControllerProvider.future);
      await container.read(savedItemsControllerProvider.notifier).addToTrip(
            item: SavedItem(
              id: 'saved-restaurant',
              category: SavedItemCategory.restaurant,
              title: 'Canal-side dinner',
              subtitle: 'French bistro',
              location: 'Paris',
              provider: 'ITAREVO Demo Restaurants',
              savedAt: DateTime(2026, 8, 19),
              price: 54,
              currency: 'GBP',
              scheduledAt: DateTime(2026, 9, 2, 19),
              notes: 'Quiet table.',
            ),
            tripId: 'trip-1',
          );

      expect(activityRepository.addedActivities, hasLength(1));
      final activity = activityRepository.addedActivities.single;
      expect(activity.tripId, 'trip-1');
      expect(activity.title, 'Canal-side dinner');
      expect(activity.location, 'Paris');
      expect(activity.status, 'Restaurant planned');
      expect(activity.cost, 54);
    });
  });
}

TravelDiscoveryResult _restaurantResult() {
  return TravelDiscoveryResult(
    id: 'demo-restaurant',
    category: DiscoveryCategory.restaurants,
    title: 'Canal-side dinner',
    subtitle: 'French bistro',
    provider: 'ITAREVO Demo Restaurants',
    location: 'Paris',
    startTime: DateTime(2026, 9, 2, 19),
    endTime: DateTime(2026, 9, 2, 21),
    duration: '2h',
    price: 54,
    currency: 'GBP',
    rating: 4.7,
    details: 'Deterministic demo restaurant.',
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
