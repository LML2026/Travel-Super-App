import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/data/services/trip_document_storage_service.dart';
import 'package:travel_super_app/features/trips/data/services/trip_document_file_service.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_document_upload.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_document.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_document_provider.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_data_scope_provider.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_document_repository.dart';

class _MemoryDocumentRepository implements TripDocumentRepository {
  final documents = <TripDocument>[];

  @override
  Future<void> addDocument(TripDocument document) async =>
      documents.add(document);

  @override
  Future<void> updateDocument(TripDocument document) async {}

  @override
  Future<void> deleteDocument({
    required String tripId,
    required String documentId,
    TripDocument? document,
  }) async {
    documents.removeWhere((item) => item.id == documentId);
  }

  @override
  Stream<List<TripDocument>> watchDocuments(String tripId) =>
      Stream.value(documents.where((item) => item.tripId == tripId).toList());
}

class _FakeDocumentStorage implements TripDocumentStorageService {
  final deleted = <String>[];

  @override
  Future<String> upload({
    required String ownerUserId,
    required String tripId,
    required String documentId,
    required TripDocumentUpload upload,
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(1);
    return 'users/$ownerUserId/trips/$tripId/documents/$documentId/${upload.fileName}';
  }

  @override
  Future<void> open(
      {required String storagePath, required String fileName}) async {}

  @override
  Future<void> delete(String storagePath) async => deleted.add(storagePath);
}

class _UnavailableDocumentStorage implements TripDocumentStorageService {
  @override
  Future<String> upload({
    required String ownerUserId,
    required String tripId,
    required String documentId,
    required TripDocumentUpload upload,
    void Function(double progress)? onProgress,
  }) async {
    throw StateError('Firebase Storage is not enabled.');
  }

  @override
  Future<void> open({required String storagePath, required String fileName}) {
    throw StateError('Firebase Storage is not enabled.');
  }

  @override
  Future<void> delete(String storagePath) {
    throw StateError('Firebase Storage is not enabled.');
  }
}

void main() {
  test('new uploads use scoped storage metadata instead of inline Base64',
      () async {
    final repository = _MemoryDocumentRepository();
    final storage = _FakeDocumentStorage();
    final actions = TripDocumentActions(
      repository,
      const TripDocumentFileService(),
      'editor-1',
      repositoryFactory: (_) => repository,
      scopeResolver: (_) async => const TripDataScope(
        tripId: 'trip-1',
        ownerUserId: 'owner-1',
        isShared: true,
        role: 'editor',
      ),
      storageService: storage,
    );

    await actions.addDocument(
      tripId: 'trip-1',
      title: 'Ticket',
      type: 'Ticket',
      reference: 'PNR-1',
      upload: const TripDocumentUpload(
        fileName: 'ticket.pdf',
        contentType: 'application/pdf',
        bytes: [1, 2, 3],
      ),
    );

    final document = repository.documents.single;
    expect(document.storagePath, contains('users/owner-1/trips/trip-1'));
    expect(document.inlineBase64, isNull);
    expect(document.uploadedBy, 'editor-1');

    await actions.deleteDocument(
      tripId: 'trip-1',
      documentId: document.id,
      document: document,
    );
    expect(storage.deleted, [document.storagePath]);
  });

  test('storage-unavailable upload does not persist partial document metadata',
      () async {
    final repository = _MemoryDocumentRepository();
    final actions = TripDocumentActions(
      repository,
      const TripDocumentFileService(),
      'owner-1',
      repositoryFactory: (_) => repository,
      scopeResolver: (_) async => const TripDataScope(
        tripId: 'trip-1',
        ownerUserId: 'owner-1',
        isShared: false,
        role: 'owner',
      ),
      storageService: _UnavailableDocumentStorage(),
    );

    await expectLater(
      actions.addDocument(
        tripId: 'trip-1',
        title: 'Ticket',
        type: 'Ticket',
        reference: 'PNR-1',
        upload: const TripDocumentUpload(
          fileName: 'ticket.pdf',
          contentType: 'application/pdf',
          bytes: [1, 2, 3],
        ),
      ),
      throwsA(isA<StateError>()),
    );
    expect(repository.documents, isEmpty);
  });
}
