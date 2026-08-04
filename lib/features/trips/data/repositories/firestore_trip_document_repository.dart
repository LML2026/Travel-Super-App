import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip_document.dart';
import '../../domain/repositories/trip_document_repository.dart';

class FirestoreTripDocumentRepository implements TripDocumentRepository {
  FirestoreTripDocumentRepository({
    FirebaseFirestore? firestore,
    required String userId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _userId = userId;

  final FirebaseFirestore _firestore;
  final String _userId;

  CollectionReference<Map<String, dynamic>> _collection(String tripId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('trips')
        .doc(tripId)
        .collection('documents');
  }

  TripDocument _fromMap(Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    }

    return TripDocument(
      id: data['id'] as String,
      tripId: data['tripId'] as String,
      title: data['title'] as String? ?? '',
      type: data['type'] as String? ?? 'General',
      reference: data['reference'] as String? ?? '',
      notes: data['notes'] as String?,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> _toMap(TripDocument document) {
    return {
      'id': document.id,
      'tripId': document.tripId,
      'title': document.title,
      'type': document.type,
      'reference': document.reference,
      'notes': document.notes,
      'createdAt': document.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(document.createdAt!),
    };
  }

  @override
  Stream<List<TripDocument>> watchDocuments(String tripId) {
    return _collection(tripId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromMap(doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Future<void> addDocument(TripDocument document) async {
    await _collection(
      document.tripId,
    ).doc(document.id).set(_toMap(document), SetOptions(merge: true));
  }

  @override
  Future<void> deleteDocument({
    required String tripId,
    required String documentId,
  }) async {
    await _collection(tripId).doc(documentId).delete();
  }
}
