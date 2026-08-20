import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/firestore_trip_document_repository.dart';
import '../../data/services/trip_document_file_service.dart';
import '../../data/services/trip_document_storage_service.dart';
import '../../domain/entities/trip_document.dart';
import '../../domain/entities/trip_document_upload.dart';
import '../../domain/repositories/trip_document_repository.dart';
import 'trip_data_scope_provider.dart';

typedef TripDocumentRepositoryFactory = TripDocumentRepository Function(
  String userId,
);

final tripDocumentRepositoryFactoryProvider =
    Provider<TripDocumentRepositoryFactory>((ref) {
  return (userId) => FirestoreTripDocumentRepository(userId: userId);
});

final tripDocumentRepositoryProvider = Provider<TripDocumentRepository>((ref) {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    return const _UnauthenticatedTripDocumentRepository();
  }

  return ref.read(tripDocumentRepositoryFactoryProvider).call(user.uid);
});

final tripDocumentsProvider =
    StreamProvider.family<List<TripDocument>, String>((ref, tripId) async* {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    yield* ref.watch(tripDocumentRepositoryProvider).watchDocuments(tripId);
    return;
  }
  final scope = await ref.watch(tripDataScopeProvider(tripId).future);
  if (scope == null) {
    yield const <TripDocument>[];
    return;
  }
  yield* ref
      .read(tripDocumentRepositoryFactoryProvider)
      .call(scope.ownerUserId)
      .watchDocuments(tripId);
});

final tripDocumentFileServiceProvider =
    Provider<TripDocumentFileService>((ref) {
  return const TripDocumentFileService();
});

final tripDocumentStorageServiceProvider =
    Provider<TripDocumentStorageService>((ref) {
  return FirebaseTripDocumentStorageService();
});

final tripDocumentActionsProvider = Provider<TripDocumentActions>((ref) {
  return TripDocumentActions(
    ref.watch(tripDocumentRepositoryProvider),
    ref.watch(tripDocumentFileServiceProvider),
    ref.watch(immediateCurrentUserProvider)?.uid,
    storageService: ref.watch(tripDocumentStorageServiceProvider),
    repositoryFactory: ref.read(tripDocumentRepositoryFactoryProvider),
    scopeResolver: (tripId) => ref.read(tripDataScopeProvider(tripId).future),
  );
});

class TripDocumentActions {
  TripDocumentActions(
    this._repository,
    this._fileService,
    this._currentUserId, {
    TripDocumentRepositoryFactory? repositoryFactory,
    Future<TripDataScope?> Function(String tripId)? scopeResolver,
    TripDocumentStorageService? storageService,
  })  : _repositoryFactory = repositoryFactory,
        _scopeResolver = scopeResolver,
        _storageService = storageService;

  final TripDocumentRepository _repository;
  final TripDocumentFileService _fileService;
  final String? _currentUserId;
  final TripDocumentRepositoryFactory? _repositoryFactory;
  final Future<TripDataScope?> Function(String tripId)? _scopeResolver;
  final TripDocumentStorageService? _storageService;

  Future<TripDocumentRepository> _repositoryFor(String tripId) async {
    final scope = await _scopeResolver?.call(tripId);
    if (scope != null && _repositoryFactory != null) {
      return _repositoryFactory.call(scope.ownerUserId);
    }
    return _repository;
  }

  Future<void> addDocument({
    required String tripId,
    required String title,
    required String type,
    required String reference,
    String? notes,
    TripDocumentUpload? upload,
  }) async {
    final repository = await _repositoryFor(tripId);
    final documentId = const Uuid().v4();
    final scope = await _scopeResolver?.call(tripId);
    String? storagePath;
    if (upload != null && _storageService != null && scope != null) {
      storagePath = await _storageService.upload(
        ownerUserId: scope.ownerUserId,
        tripId: tripId,
        documentId: documentId,
        upload: upload,
      );
    }
    final document = TripDocument(
      id: documentId,
      tripId: tripId,
      title: title,
      type: type,
      reference: reference,
      notes: notes,
      fileName: upload?.fileName,
      contentType: upload?.contentType,
      sizeBytes: upload?.sizeBytes,
      storagePath: storagePath,
      inlineBase64: storagePath == null && upload != null
          ? _fileService.encodeInline(upload)
          : null,
      uploadedBy: upload == null ? null : _currentUserId,
      uploadedAt: upload == null ? null : DateTime.now(),
      createdAt: DateTime.now(),
    );

    try {
      await repository.addDocument(document);
    } catch (_) {
      if (storagePath != null && _storageService != null) {
        await _storageService.delete(storagePath);
      }
      rethrow;
    }
  }

  Future<void> updateDocument(TripDocument document) async {
    return (await _repositoryFor(document.tripId)).updateDocument(document);
  }

  Future<void> deleteDocument({
    required String tripId,
    required String documentId,
    TripDocument? document,
  }) {
    return _deleteDocument(
      repository: _repositoryFor(tripId),
      tripId: tripId,
      documentId: documentId,
      document: document,
    );
  }

  Future<void> _deleteDocument({
    required Future<TripDocumentRepository> repository,
    required String tripId,
    required String documentId,
    TripDocument? document,
  }) async {
    final storagePath = document?.storagePath;
    if (storagePath != null && _storageService != null) {
      await _storageService.delete(storagePath);
    }
    await (await repository).deleteDocument(
      tripId: tripId,
      documentId: documentId,
      document: document,
    );
  }

  Future<TripDocumentUpload> readLocalFile(String path) {
    return _fileService.readLocalFile(path);
  }

  Future<void> openDocument(TripDocument document) {
    if (document.storagePath != null && _storageService != null) {
      return _storageService.open(
        storagePath: document.storagePath!,
        fileName: document.fileName ?? document.id,
      );
    }
    return _fileService.openDocument(document);
  }
}

class TripDocumentMutationState {
  const TripDocumentMutationState({
    this.isLoading = false,
    this.progress,
    this.successMessage,
    this.errorMessage,
  });

  final bool isLoading;
  final double? progress;
  final String? successMessage;
  final String? errorMessage;
}

class TripDocumentMutationController
    extends AutoDisposeAsyncNotifier<TripDocumentMutationState> {
  @override
  FutureOr<TripDocumentMutationState> build() {
    return const TripDocumentMutationState();
  }

  Future<TripDocumentUpload> readLocalFile(String path) async {
    state = const AsyncData(
      TripDocumentMutationState(isLoading: true, progress: 0.15),
    );
    try {
      final upload =
          await ref.read(tripDocumentActionsProvider).readLocalFile(path);
      state = const AsyncData(
        TripDocumentMutationState(
          isLoading: false,
          progress: 1,
          successMessage: 'File ready to upload.',
        ),
      );
      return upload;
    } catch (error) {
      state = AsyncData(
        TripDocumentMutationState(
          errorMessage: error.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<void> openDocument(TripDocument document) async {
    state = const AsyncData(TripDocumentMutationState(isLoading: true));
    try {
      await ref.read(tripDocumentActionsProvider).openDocument(document);
      state = const AsyncData(
        TripDocumentMutationState(successMessage: 'Document opened.'),
      );
    } catch (error) {
      state = AsyncData(
        TripDocumentMutationState(errorMessage: error.toString()),
      );
      rethrow;
    }
  }
}

final tripDocumentMutationProvider = AutoDisposeAsyncNotifierProvider<
    TripDocumentMutationController, TripDocumentMutationState>(
  TripDocumentMutationController.new,
);

class _UnauthenticatedTripDocumentRepository implements TripDocumentRepository {
  const _UnauthenticatedTripDocumentRepository();

  @override
  Future<void> addDocument(TripDocument document) async {
    throw StateError('Authentication required to manage trip documents.');
  }

  @override
  Future<void> updateDocument(TripDocument document) async {
    throw StateError('Authentication required to manage trip documents.');
  }

  @override
  Future<void> deleteDocument({
    required String tripId,
    required String documentId,
    TripDocument? document,
  }) async {
    throw StateError('Authentication required to manage trip documents.');
  }

  @override
  Stream<List<TripDocument>> watchDocuments(String tripId) {
    return Stream.value(const <TripDocument>[]);
  }
}
