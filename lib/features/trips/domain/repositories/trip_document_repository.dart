import '../entities/trip_document.dart';

abstract interface class TripDocumentRepository {
  Stream<List<TripDocument>> watchDocuments(String tripId);

  Future<void> addDocument(TripDocument document);

  Future<void> deleteDocument({
    required String tripId,
    required String documentId,
  });
}
