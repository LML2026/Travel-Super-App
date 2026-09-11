import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/firestore_trip_collaboration_repository.dart';
import '../../domain/entities/trip_collaborator.dart';
import '../../domain/repositories/trip_collaboration_repository.dart';
import 'trip_data_scope_provider.dart';

typedef TripCollaborationRepositoryFactory = TripCollaborationRepository
    Function(
  String ownerUserId,
);

final tripCollaborationRepositoryFactoryProvider =
    Provider<TripCollaborationRepositoryFactory>((ref) {
  return (ownerUserId) =>
      FirestoreTripCollaborationRepository(ownerUserId: ownerUserId);
});

final tripCollaborationRepositoryProvider =
    Provider<TripCollaborationRepository>((ref) {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    return const _UnauthenticatedTripCollaborationRepository();
  }
  return ref.read(tripCollaborationRepositoryFactoryProvider).call(user.uid);
});

final tripCollaboratorsProvider =
    StreamProvider.family<List<TripCollaborator>, String>((ref, tripId) async* {
  final scope = await ref.watch(tripDataScopeProvider(tripId).future);
  if (scope == null) {
    yield const <TripCollaborator>[];
    return;
  }
  yield* ref
      .read(tripCollaborationRepositoryFactoryProvider)
      .call(scope.ownerUserId)
      .watchCollaborators(tripId);
});

final tripCollaborationActionsProvider =
    Provider<TripCollaborationActions>((ref) {
  final user = ref.watch(immediateCurrentUserProvider);
  return TripCollaborationActions(
    ref.watch(tripCollaborationRepositoryProvider),
    invitedBy: user?.uid,
  );
});

class TripCollaborationActions {
  TripCollaborationActions(
    this._repository, {
    required String? invitedBy,
  }) : _invitedBy = invitedBy;

  final TripCollaborationRepository _repository;
  final String? _invitedBy;

  Future<void> inviteCollaborator({
    required String tripId,
    required String email,
    required TripCollaboratorRole role,
    String? userId,
    String? displayName,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw ArgumentError('Enter a valid collaborator email.');
    }

    final collaborator = TripCollaborator(
      id: const Uuid().v4(),
      tripId: tripId,
      email: normalizedEmail,
      role: role,
      status: TripCollaboratorStatus.invited,
      userId: userId?.trim().isEmpty == true ? null : userId?.trim(),
      displayName:
          displayName?.trim().isEmpty == true ? null : displayName?.trim(),
      invitedBy: _invitedBy,
      invitedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _repository.inviteCollaborator(collaborator);
  }

  Future<void> updateRole({
    required String tripId,
    required String collaboratorId,
    required TripCollaboratorRole role,
  }) {
    if (role == TripCollaboratorRole.owner) {
      throw ArgumentError('Owner role cannot be assigned from this panel.');
    }
    return _repository.updateCollaboratorRole(
      tripId: tripId,
      collaboratorId: collaboratorId,
      role: role,
    );
  }

  Future<void> removeCollaborator({
    required String tripId,
    required String collaboratorId,
  }) {
    return _repository.removeCollaborator(
      tripId: tripId,
      collaboratorId: collaboratorId,
    );
  }
}

class _UnauthenticatedTripCollaborationRepository
    implements TripCollaborationRepository {
  const _UnauthenticatedTripCollaborationRepository();

  @override
  Future<void> inviteCollaborator(TripCollaborator collaborator) async {
    throw StateError('Authentication required to manage collaborators.');
  }

  @override
  Future<void> removeCollaborator({
    required String tripId,
    required String collaboratorId,
  }) async {
    throw StateError('Authentication required to manage collaborators.');
  }

  @override
  Future<void> updateCollaboratorRole({
    required String tripId,
    required String collaboratorId,
    required TripCollaboratorRole role,
  }) async {
    throw StateError('Authentication required to manage collaborators.');
  }

  @override
  Stream<List<TripCollaborator>> watchCollaborators(String tripId) {
    return Stream.value(const []);
  }
}
