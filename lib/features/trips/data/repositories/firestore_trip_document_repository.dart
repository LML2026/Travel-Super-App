import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip_document.dart';
import '../../domain/repositories/trip_document_repository.dart';

class FirestoreTripDocumentRepository implements TripDocumentRepository {
  FirestoreTripDocumentRepository({
    FirebaseFirestore? firestore,
    required String userId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
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
    final uploadedAtRaw = data['uploadedAt'];
    DateTime? uploadedAt;
    if (uploadedAtRaw is Timestamp) {
      uploadedAt = uploadedAtRaw.toDate();
    } else if (uploadedAtRaw is DateTime) {
      uploadedAt = uploadedAtRaw;
    }

    return TripDocument(
      id: data['id'] as String,
      tripId: data['tripId'] as String,
      title: data['title'] as String? ?? '',
      type: data['type'] as String? ?? 'General',
      reference: data['reference'] as String? ?? '',
      notes: data['notes'] as String?,
      fileName: data['fileName'] as String?,
      contentType: data['contentType'] as String?,
      sizeBytes: data['sizeBytes'] as int?,
      downloadUrl: data['downloadUrl'] as String?,
      storagePath: data['storagePath'] as String?,
      inlineBase64: data['inlineBase64'] as String?,
      uploadedBy: data['uploadedBy'] as String?,
      uploadedAt: uploadedAt,
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
      'fileName': document.fileName,
      'contentType': document.contentType,
      'sizeBytes': document.sizeBytes,
      'downloadUrl': document.downloadUrl,
      'storagePath': document.storagePath,
      'inlineBase64': document.inlineBase64,
      'uploadedBy': document.uploadedBy,
      'uploadedAt': document.uploadedAt == null
          ? null
          : Timestamp.fromDate(document.uploadedAt!),
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
        .map((snapshot) => snapshot.docs
            .map((doc) => _fromMap(doc.data()))
            .toList(growable: false));
  }

  @override
  Future<void> addDocument(TripDocument document) async {
    await _collection(document.tripId)
        .doc(document.id)
        .set(_toMap(document), SetOptions(merge: true));
  }

  @override
  Future<void> updateDocument(TripDocument document) async {
    await _collection(document.tripId)
        .doc(document.id)
        .set(_toMap(document), SetOptions(merge: true));
  }

  @override
  Future<void> deleteDocument({
    required String tripId,
    required String documentId,
    TripDocument? document,
  }) async {
    await _collection(tripId).doc(documentId).delete();
  }
}
