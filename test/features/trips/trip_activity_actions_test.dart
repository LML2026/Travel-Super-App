import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_activity.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_activity_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_activity_provider.dart';

void main() {
  test('TripActivityActions updates matching activity instead of duplicating',
      () async {
    final repository = _MemoryTripActivityRepository([
      TripActivity(
        id: 'activity-1',
        tripId: 'trip-1',
        title: 'Canal-side dinner',
        location: 'Paris',
        scheduledAt: DateTime(2026, 9, 2, 19),
        status: 'Restaurant planned',
      ),
    ]);
    final container = ProviderContainer(
      overrides: [
        tripActivityRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(tripActivityActionsProvider).addActivity(
          tripId: 'trip-1',
          title: 'Canal-side dinner',
          location: 'Paris',
          scheduledAt: DateTime(2026, 9, 2, 19),
          notes: 'Updated from saved item.',
          cost: 54,
          currency: 'GBP',
          status: 'Restaurant planned',
        );

    expect(repository.activities, hasLength(1));
    expect(repository.activities.single.notes, 'Updated from saved item.');
    expect(repository.activities.single.cost, 54);
  });
}

class _MemoryTripActivityRepository implements TripActivityRepository {
  _MemoryTripActivityRepository([List<TripActivity>? initial])
      : activities = [...?initial];

  final List<TripActivity> activities;

  @override
  Future<void> addActivity(TripActivity activity) async {
    activities.add(activity);
  }

  @override
  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) async {
    activities.removeWhere(
      (activity) => activity.tripId == tripId && activity.id == activityId,
    );
  }

  @override
  Future<void> updateActivity(TripActivity activity) async {
    final index = activities.indexWhere(
      (existing) =>
          existing.tripId == activity.tripId && existing.id == activity.id,
    );
    if (index == -1) {
      activities.add(activity);
      return;
    }
    activities[index] = activity;
  }

  @override
  Stream<List<TripActivity>> watchActivities(String tripId) {
    return Stream.value(
      activities.where((activity) => activity.tripId == tripId).toList(),
    );
  }
}
