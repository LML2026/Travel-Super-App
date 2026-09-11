import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/firestore_trip_activity_repository.dart';
import '../../domain/entities/trip_activity.dart';
import '../../domain/repositories/trip_activity_repository.dart';
import 'trip_data_scope_provider.dart';

typedef TripActivityRepositoryFactory = TripActivityRepository Function(
  String userId,
);

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
    StreamProvider.family<List<TripActivity>, String>((ref, tripId) async* {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    yield* ref.watch(tripActivityRepositoryProvider).watchActivities(tripId);
    return;
  }
  final scope = await ref.watch(tripDataScopeProvider(tripId).future);
  if (scope == null) {
    yield const <TripActivity>[];
    return;
  }
  yield* ref
      .read(tripActivityRepositoryFactoryProvider)
      .call(scope.ownerUserId)
      .watchActivities(tripId);
});

final tripActivityActionsProvider = Provider<TripActivityActions>((ref) {
  return TripActivityActions(
    ref.watch(tripActivityRepositoryProvider),
    repositoryFactory: ref.read(tripActivityRepositoryFactoryProvider),
    scopeResolver: (tripId) => ref.read(tripDataScopeProvider(tripId).future),
  );
});

class TripActivityActions {
  TripActivityActions(
    this._repository, {
    TripActivityRepositoryFactory? repositoryFactory,
    Future<TripDataScope?> Function(String tripId)? scopeResolver,
  })  : _repositoryFactory = repositoryFactory,
        _scopeResolver = scopeResolver;

  final TripActivityRepository _repository;
  final TripActivityRepositoryFactory? _repositoryFactory;
  final Future<TripDataScope?> Function(String tripId)? _scopeResolver;

  Future<TripActivityRepository> _repositoryFor(String tripId) async {
    try {
      final scope = await _scopeResolver?.call(tripId);
      if (scope != null && _repositoryFactory != null) {
        return _repositoryFactory.call(scope.ownerUserId);
      }
    } catch (_) {
      // Keep injected/local repositories usable without Firebase initialization.
    }
    return _repository;
  }

  Future<void> addActivity({
    required String tripId,
    required String title,
    String? location,
    String? notes,
    DateTime? scheduledAt,
    double? cost,
    String? currency,
    String? status,
  }) async {
    final repository = await _repositoryFor(tripId);
    final existing = await repository.watchActivities(tripId).first;
    TripActivity? duplicate;
    for (final activity in existing) {
      if (_normal(activity.title) == _normal(title) &&
          _normal(activity.location) == _normal(location) &&
          _sameMoment(activity.scheduledAt, scheduledAt)) {
        duplicate = activity;
        break;
      }
    }

    if (duplicate != null) {
      await repository.updateActivity(
        duplicate.copyWith(
          notes: notes ?? duplicate.notes,
          cost: cost ?? duplicate.cost,
          currency: currency ?? duplicate.currency,
          status: status ?? duplicate.status,
        ),
      );
      return;
    }

    final activity = TripActivity(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      location: location,
      notes: notes,
      scheduledAt: scheduledAt,
      cost: cost,
      currency: currency,
      status: status,
      createdAt: DateTime.now(),
    );

    await repository.addActivity(activity);
  }

  Future<void> updateActivity(TripActivity activity) async {
    final repository = await _repositoryFor(activity.tripId);
    return repository.updateActivity(activity);
  }

  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) async {
    final repository = await _repositoryFor(tripId);
    return repository.deleteActivity(tripId: tripId, activityId: activityId);
  }
}

String _normal(String? value) => (value ?? '').trim().toLowerCase();

bool _sameMoment(DateTime? left, DateTime? right) {
  if (left == null && right == null) return true;
  if (left == null || right == null) return false;
  return left.toIso8601String() == right.toIso8601String();
}

class _UnauthenticatedTripActivityRepository implements TripActivityRepository {
  const _UnauthenticatedTripActivityRepository();

  @override
  Future<void> addActivity(TripActivity activity) async {
    throw StateError('Authentication required to manage trip activities.');
  }

  @override
  Future<void> updateActivity(TripActivity activity) async {
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
