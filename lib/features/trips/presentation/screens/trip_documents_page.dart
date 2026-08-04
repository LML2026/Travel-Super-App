import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/trip_document_provider.dart';

class TripDocumentsPage extends ConsumerWidget {
  const TripDocumentsPage({super.key, required this.tripId});

  final String tripId;

  Future<void> _showAddDocumentDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final titleController = TextEditingController();
    final typeController = TextEditingController(text: 'General');
    final referenceController = TextEditingController();
    final notesController = TextEditingController();

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Document'),
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
                  decoration: const InputDecoration(labelText: 'Type'),
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

                await ref
                    .read(tripDocumentActionsProvider)
                    .addDocument(
                      tripId: tripId,
                      title: title,
                      type: type,
                      reference: reference,
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                    );

                if (context.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text('Add'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trip document added.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(tripDocumentsProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Documents')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDocumentDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: documentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load documents: $error')),
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
                  subtitle: Text('${document.type} | ${document.reference}'),
                  trailing: IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref
                          .read(tripDocumentActionsProvider)
                          .deleteDocument(
                            tripId: tripId,
                            documentId: document.id,
                          );
                    },
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
