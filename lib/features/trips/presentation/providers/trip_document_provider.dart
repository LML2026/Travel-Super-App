import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/firestore_trip_document_repository.dart';
import '../../data/services/trip_document_file_service.dart';
import '../../domain/entities/trip_document.dart';
import '../../domain/entities/trip_document_upload.dart';
import '../../domain/repositories/trip_document_repository.dart';

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
    StreamProvider.family<List<TripDocument>, String>((ref, tripId) {
  return ref.watch(tripDocumentRepositoryProvider).watchDocuments(tripId);
});

final tripDocumentFileServiceProvider =
    Provider<TripDocumentFileService>((ref) {
  return const TripDocumentFileService();
});

final tripDocumentActionsProvider = Provider<TripDocumentActions>((ref) {
  return TripDocumentActions(
    ref.watch(tripDocumentRepositoryProvider),
    ref.watch(tripDocumentFileServiceProvider),
    ref.watch(immediateCurrentUserProvider)?.uid,
  );
});

class TripDocumentActions {
  TripDocumentActions(
    this._repository,
    this._fileService,
    this._currentUserId,
  );

  final TripDocumentRepository _repository;
  final TripDocumentFileService _fileService;
  final String? _currentUserId;

  Future<void> addDocument({
    required String tripId,
    required String title,
    required String type,
    required String reference,
    String? notes,
    TripDocumentUpload? upload,
  }) async {
    final document = TripDocument(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      type: type,
      reference: reference,
      notes: notes,
      fileName: upload?.fileName,
      contentType: upload?.contentType,
      sizeBytes: upload?.sizeBytes,
      inlineBase64: upload == null ? null : _fileService.encodeInline(upload),
      uploadedBy: upload == null ? null : _currentUserId,
      uploadedAt: upload == null ? null : DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _repository.addDocument(document);
  }

  Future<void> updateDocument(TripDocument document) {
    return _repository.updateDocument(document);
  }

  Future<void> deleteDocument({
    required String tripId,
    required String documentId,
    TripDocument? document,
  }) {
    return _repository.deleteDocument(
      tripId: tripId,
      documentId: documentId,
      document: document,
    );
  }

  Future<TripDocumentUpload> readLocalFile(String path) {
    return _fileService.readLocalFile(path);
  }

  Future<void> openDocument(TripDocument document) {
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
