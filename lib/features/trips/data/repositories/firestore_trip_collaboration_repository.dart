import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip_collaborator.dart';
import '../../domain/repositories/trip_collaboration_repository.dart';

class FirestoreTripCollaborationRepository
    implements TripCollaborationRepository {
  FirestoreTripCollaborationRepository({
    FirebaseFirestore? firestore,
    required String ownerUserId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _ownerUserId = ownerUserId;

  final FirebaseFirestore _firestore;
  final String _ownerUserId;

  CollectionReference<Map<String, dynamic>> _collection(String tripId) {
    return _firestore
        .collection('users')
        .doc(_ownerUserId)
        .collection('trips')
        .doc(tripId)
        .collection('collaborators');
  }

  @override
  Stream<List<TripCollaborator>> watchCollaborators(String tripId) {
    return _collection(tripId)
        .orderBy('invitedAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromMap(doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Future<void> inviteCollaborator(TripCollaborator collaborator) async {
    final batch = _firestore.batch();
    final collaboratorRef =
        _collection(collaborator.tripId).doc(collaborator.id);
    batch.set(collaboratorRef, _toMap(collaborator), SetOptions(merge: true));

    final collaboratorUserId = collaborator.userId;
    if (collaboratorUserId != null && collaboratorUserId.isNotEmpty) {
      final sharedRef = _firestore
          .collection('users')
          .doc(collaboratorUserId)
          .collection('sharedTrips')
          .doc(collaborator.tripId);
      batch.set(
          sharedRef,
          {
            'tripId': collaborator.tripId,
            'ownerUserId': _ownerUserId,
            'role': collaborator.role.name,
            'status': collaborator.status.name,
            'sharedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    }

    await batch.commit();
  }

  @override
  Future<void> updateCollaboratorRole({
    required String tripId,
    required String collaboratorId,
    required TripCollaboratorRole role,
  }) async {
    final collaboratorRef = _collection(tripId).doc(collaboratorId);
    final snapshot = await collaboratorRef.get();
    final collaboratorUserId = snapshot.data()?['userId'] as String?;
    final batch = _firestore.batch();
    batch.set(
        collaboratorRef,
        {
          'role': role.name,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));
    if (collaboratorUserId != null && collaboratorUserId.isNotEmpty) {
      batch.set(
        _sharedRef(collaboratorUserId, tripId),
        {'role': role.name, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  @override
  Future<void> removeCollaborator({
    required String tripId,
    required String collaboratorId,
  }) async {
    final collaboratorRef = _collection(tripId).doc(collaboratorId);
    final snapshot = await collaboratorRef.get();
    final collaboratorUserId = snapshot.data()?['userId'] as String?;
    final batch = _firestore.batch()..delete(collaboratorRef);
    if (collaboratorUserId != null && collaboratorUserId.isNotEmpty) {
      batch.delete(_sharedRef(collaboratorUserId, tripId));
    }
    await batch.commit();
  }

  DocumentReference<Map<String, dynamic>> _sharedRef(
    String collaboratorUserId,
    String tripId,
  ) {
    return _firestore
        .collection('users')
        .doc(collaboratorUserId)
        .collection('sharedTrips')
        .doc(tripId);
  }

  TripCollaborator _fromMap(Map<String, dynamic> data) {
    return TripCollaborator(
      id: data['id'] as String? ?? '',
      tripId: data['tripId'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: TripCollaboratorRole.values.firstWhere(
        (role) => role.name == data['role'],
        orElse: () => TripCollaboratorRole.viewer,
      ),
      status: TripCollaboratorStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => TripCollaboratorStatus.invited,
      ),
      userId: data['userId'] as String?,
      displayName: data['displayName'] as String?,
      invitedBy: data['invitedBy'] as String?,
      invitedAt: _dateFrom(data['invitedAt']),
      updatedAt: _dateFrom(data['updatedAt']),
    );
  }

  Map<String, dynamic> _toMap(TripCollaborator collaborator) {
    return {
      'id': collaborator.id,
      'tripId': collaborator.tripId,
      'email': collaborator.email,
      'role': collaborator.role.name,
      'status': collaborator.status.name,
      'userId': collaborator.userId,
      'displayName': collaborator.displayName,
      'invitedBy': collaborator.invitedBy,
      'invitedAt': collaborator.invitedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(collaborator.invitedAt!),
      'updatedAt': collaborator.updatedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(collaborator.updatedAt!),
    };
  }

  DateTime? _dateFrom(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
