import '../entities/trip_collaborator.dart';

abstract interface class TripCollaborationRepository {
  Stream<List<TripCollaborator>> watchCollaborators(String tripId);

  Future<void> inviteCollaborator(TripCollaborator collaborator);

  Future<void> updateCollaboratorRole({
    required String tripId,
    required String collaboratorId,
    required TripCollaboratorRole role,
  });

  Future<void> removeCollaborator({
    required String tripId,
    required String collaboratorId,
  });
}
