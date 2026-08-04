import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/firestore_trip_activity_repository.dart';
import '../../domain/entities/trip_activity.dart';
import '../../domain/repositories/trip_activity_repository.dart';

typedef TripActivityRepositoryFactory =
    TripActivityRepository Function(String userId);

final tripActivityRepositoryFactoryProvider =
    Provider<TripActivityRepositoryFactory>((ref) {
      return (userId) => FirestoreTripActivityRepository(userId: userId);
    });

final tripActivityRepositoryProvider = Provider<TripActivityRepository>((ref) {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    return const _UnauthenticatedTripActivityRepository();
  }

  return ref.read(tripActivityRepositoryFactoryProvider).call(user.uid);
});

final tripActivitiesProvider =
    StreamProvider.family<List<TripActivity>, String>((ref, tripId) {
      return ref.watch(tripActivityRepositoryProvider).watchActivities(tripId);
    });

final tripActivityActionsProvider = Provider<TripActivityActions>((ref) {
  return TripActivityActions(ref.watch(tripActivityRepositoryProvider));
});

class TripActivityActions {
  TripActivityActions(this._repository);

  final TripActivityRepository _repository;

  Future<void> addActivity({
    required String tripId,
    required String title,
    String? location,
    String? notes,
    DateTime? scheduledAt,
  }) async {
    final activity = TripActivity(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      location: location,
      notes: notes,
      scheduledAt: scheduledAt,
      createdAt: DateTime.now(),
    );

    await _repository.addActivity(activity);
  }

  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) {
    return _repository.deleteActivity(tripId: tripId, activityId: activityId);
  }
}

class _UnauthenticatedTripActivityRepository implements TripActivityRepository {
  const _UnauthenticatedTripActivityRepository();

  @override
  Future<void> addActivity(TripActivity activity) async {
    throw StateError('Authentication required to manage trip activities.');
  }

  @override
  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) async {
    throw StateError('Authentication required to manage trip activities.');
  }

  @override
  Stream<List<TripActivity>> watchActivities(String tripId) {
    return Stream.value(const <TripActivity>[]);
  }
}
