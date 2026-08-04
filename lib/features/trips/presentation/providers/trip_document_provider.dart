import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/firestore_trip_document_repository.dart';
import '../../domain/entities/trip_document.dart';
import '../../domain/repositories/trip_document_repository.dart';

typedef TripDocumentRepositoryFactory =
    TripDocumentRepository Function(String userId);

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

final tripDocumentsProvider = StreamProvider.family<List<TripDocument>, String>(
  (ref, tripId) {
    return ref.watch(tripDocumentRepositoryProvider).watchDocuments(tripId);
  },
);

final tripDocumentActionsProvider = Provider<TripDocumentActions>((ref) {
  return TripDocumentActions(ref.watch(tripDocumentRepositoryProvider));
});

class TripDocumentActions {
  TripDocumentActions(this._repository);

  final TripDocumentRepository _repository;

  Future<void> addDocument({
    required String tripId,
    required String title,
    required String type,
    required String reference,
    String? notes,
  }) async {
    final document = TripDocument(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      type: type,
      reference: reference,
      notes: notes,
      createdAt: DateTime.now(),
    );

    await _repository.addDocument(document);
  }

  Future<void> deleteDocument({
    required String tripId,
    required String documentId,
  }) {
    return _repository.deleteDocument(tripId: tripId, documentId: documentId);
  }
}

class _UnauthenticatedTripDocumentRepository implements TripDocumentRepository {
  const _UnauthenticatedTripDocumentRepository();

  @override
  Future<void> addDocument(TripDocument document) async {
    throw StateError('Authentication required to manage trip documents.');
  }

  @override
  Future<void> deleteDocument({
    required String tripId,
    required String documentId,
  }) async {
    throw StateError('Authentication required to manage trip documents.');
  }

  @override
  Stream<List<TripDocument>> watchDocuments(String tripId) {
    return Stream.value(const <TripDocument>[]);
  }
}
