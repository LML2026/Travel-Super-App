import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trip_document.dart';
import '../providers/trip_document_provider.dart';

class TripDocumentsPage extends ConsumerWidget {
  const TripDocumentsPage({
    super.key,
    required this.tripId,
  });

  final String tripId;

  Future<void> _showDocumentDialog(
    BuildContext context,
    WidgetRef ref, {
    TripDocument? document,
  }) async {
    final titleController = TextEditingController(text: document?.title);
    final typeController =
        TextEditingController(text: document?.type ?? 'Confirmation');
    final referenceController =
        TextEditingController(text: document?.reference);
    final notesController = TextEditingController(text: document?.notes);
    final isEditing = document != null;

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Document' : 'Add Document'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    hintText: 'Ticket, confirmation, passport, visa',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Reference / URL / Code',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final type = typeController.text.trim();
                final reference = referenceController.text.trim();
                if (title.isEmpty || type.isEmpty || reference.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Title, type, and reference are required.'),
                    ),
                  );
                  return;
                }

                final notes = notesController.text.trim();
                if (isEditing) {
                  await ref.read(tripDocumentActionsProvider).updateDocument(
                        document.copyWith(
                          title: title,
                          type: type,
                          reference: reference,
                          notes: notes.isEmpty ? null : notes,
                        ),
                      );
                } else {
                  await ref.read(tripDocumentActionsProvider).addDocument(
                        tripId: tripId,
                        title: title,
                        type: type,
                        reference: reference,
                        notes: notes.isEmpty ? null : notes,
                      );
                }

                if (context.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    typeController.dispose();
    referenceController.dispose();
    notesController.dispose();

    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Trip document updated.' : 'Trip document added.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(tripDocumentsProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Documents')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDocumentDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: documentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load documents: $error')),
        data: (documents) {
          if (documents.isEmpty) {
            return const Center(
              child: Text('No trip documents yet. Add your first reference.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final document = documents[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(document.title),
                  subtitle: Text(
                    [
                      document.type,
                      document.reference,
                      if (document.notes?.trim().isNotEmpty == true)
                        document.notes!.trim(),
                    ].join(' | '),
                  ),
                  onTap: () => _showDocumentDialog(
                    context,
                    ref,
                    document: document,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await _showDocumentDialog(
                          context,
                          ref,
                          document: document,
                        );
                        return;
                      }

                      await ref.read(tripDocumentActionsProvider).deleteDocument(
                            tripId: tripId,
                            documentId: document.id,
                          );
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Remove')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
