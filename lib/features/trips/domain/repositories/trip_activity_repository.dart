import '../entities/trip_activity.dart';

abstract interface class TripActivityRepository {
  Stream<List<TripActivity>> watchActivities(String tripId);

  Future<void> addActivity(TripActivity activity);

  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  });
}
