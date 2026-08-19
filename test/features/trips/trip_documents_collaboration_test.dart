import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/trips/data/services/trip_document_file_service.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_collaborator.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_document.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip_document_upload.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_collaboration_repository.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_document_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_collaboration_provider.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_document_provider.dart';

class _FakeTripDocumentRepository implements TripDocumentRepository {
  final documents = <TripDocument>[];
  final deleted = <String>[];

  @override
  Future<void> addDocument(TripDocument document) async {
    documents.add(document);
  }

  @override
  Future<void> updateDocument(TripDocument document) async {
    final index = documents.indexWhere((item) => item.id == document.id);
    if (index == -1) {
      documents.add(document);
    } else {
      documents[index] = document;
    }
  }

  @override
  Future<void> deleteDocument({
    required String tripId,
    required String documentId,
    TripDocument? document,
  }) async {
    deleted.add(documentId);
    documents.removeWhere((item) => item.id == documentId);
  }

  @override
  Stream<List<TripDocument>> watchDocuments(String tripId) {
    return Stream.value(
      documents.where((document) => document.tripId == tripId).toList(),
    );
  }
}

class _FakeTripCollaborationRepository implements TripCollaborationRepository {
  final collaborators = <TripCollaborator>[];
  final removed = <String>[];

  @override
  Future<void> inviteCollaborator(TripCollaborator collaborator) async {
    collaborators.add(collaborator);
  }

  @override
  Future<void> removeCollaborator({
    required String tripId,
    required String collaboratorId,
  }) async {
    removed.add(collaboratorId);
    collaborators.removeWhere((item) => item.id == collaboratorId);
  }

  @override
  Future<void> updateCollaboratorRole({
    required String tripId,
    required String collaboratorId,
    required TripCollaboratorRole role,
  }) async {
    final index = collaborators.indexWhere((item) => item.id == collaboratorId);
    collaborators[index] = collaborators[index].copyWith(role: role);
  }

  @override
  Stream<List<TripCollaborator>> watchCollaborators(String tripId) {
    return Stream.value(
      collaborators
          .where((collaborator) => collaborator.tripId == tripId)
          .toList(),
    );
  }
}

void main() {
  test('document actions persist uploaded document metadata and payload',
      () async {
    final repository = _FakeTripDocumentRepository();
    final actions = TripDocumentActions(
      repository,
      const TripDocumentFileService(),
      'owner-1',
    );

    await actions.addDocument(
      tripId: 'trip-1',
      title: 'Eurostar ticket',
      type: 'Ticket',
      reference: 'PNR123',
      upload: const TripDocumentUpload(
        fileName: 'ticket.txt',
        contentType: 'text/plain',
        bytes: [72, 105],
      ),
    );

    final document = repository.documents.single;
    expect(document.fileName, 'ticket.txt');
    expect(document.sizeBytes, 2);
    expect(document.uploadedBy, 'owner-1');
    expect(document.inlineBase64, 'SGk=');
    expect(document.hasUploadedFile, isTrue);
  });

  test('document delete passes uploaded document for safe removal', () async {
    final repository = _FakeTripDocumentRepository();
    final actions = TripDocumentActions(
      repository,
      const TripDocumentFileService(),
      'owner-1',
    );
    const document = TripDocument(
      id: 'doc-1',
      tripId: 'trip-1',
      title: 'Passport',
      type: 'Passport',
      reference: 'secure-ref',
      inlineBase64: 'SGk=',
    );
    repository.documents.add(document);

    await actions.deleteDocument(
      tripId: 'trip-1',
      documentId: 'doc-1',
      document: document,
    );

    expect(repository.deleted, ['doc-1']);
    expect(repository.documents, isEmpty);
  });

  test('collaboration actions invite, update role and remove collaborator',
      () async {
    final repository = _FakeTripCollaborationRepository();
    final actions = TripCollaborationActions(repository, invitedBy: 'owner-1');

    await actions.inviteCollaborator(
      tripId: 'trip-1',
      email: 'Friend@Example.com',
      role: TripCollaboratorRole.editor,
      userId: 'friend-uid',
    );

    final collaborator = repository.collaborators.single;
    expect(collaborator.email, 'friend@example.com');
    expect(collaborator.role, TripCollaboratorRole.editor);
    expect(collaborator.userId, 'friend-uid');
    expect(collaborator.status, TripCollaboratorStatus.invited);

    await actions.updateRole(
      tripId: 'trip-1',
      collaboratorId: collaborator.id,
      role: TripCollaboratorRole.viewer,
    );
    expect(repository.collaborators.single.role, TripCollaboratorRole.viewer);

    await actions.removeCollaborator(
      tripId: 'trip-1',
      collaboratorId: collaborator.id,
    );
    expect(repository.collaborators, isEmpty);
    expect(repository.removed, [collaborator.id]);
  });
}
