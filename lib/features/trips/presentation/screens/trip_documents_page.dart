import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trip_document.dart';
import '../../domain/entities/trip_document_upload.dart';
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
    final filePathController = TextEditingController();
    final isEditing = document != null;
    TripDocumentUpload? upload;
    String? uploadError;

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                    if (!isEditing) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: filePathController,
                        decoration: const InputDecoration(
                          labelText: 'Local file path',
                          hintText: '/path/to/confirmation.pdf',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final path = filePathController.text.trim();
                            if (path.isEmpty) {
                              setDialogState(() {
                                uploadError = 'Enter a local file path first.';
                              });
                              return;
                            }
                            try {
                              final selected = await ref
                                  .read(tripDocumentMutationProvider.notifier)
                                  .readLocalFile(path);
                              setDialogState(() {
                                upload = selected;
                                uploadError = null;
                                if (titleController.text.trim().isEmpty) {
                                  titleController.text = selected.fileName;
                                }
                              });
                            } catch (error) {
                              setDialogState(() {
                                uploadError = error.toString();
                                upload = null;
                              });
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Attach File'),
                        ),
                      ),
                      if (upload != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text(upload!.fileName),
                          subtitle: Text(
                            '${upload!.contentType} | ${upload!.sizeBytes} bytes',
                          ),
                        ),
                      if (uploadError != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            uploadError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
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
                    if (title.isEmpty || type.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Title and type are required.'),
                        ),
                      );
                      return;
                    }
                    if (reference.isEmpty && upload == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Add a reference, URL, code, or uploaded file.',
                          ),
                        ),
                      );
                      return;
                    }

                    final notes = notesController.text.trim();
                    if (isEditing) {
                      await ref
                          .read(tripDocumentActionsProvider)
                          .updateDocument(
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
                            reference: reference.isEmpty
                                ? upload!.fileName
                                : reference,
                            notes: notes.isEmpty ? null : notes,
                            upload: upload,
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
      },
    );

    titleController.dispose();
    typeController.dispose();
    referenceController.dispose();
    notesController.dispose();
    filePathController.dispose();

    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isEditing ? 'Trip document updated.' : 'Trip document added.'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TripDocument document,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove document?'),
        content: Text(
          document.hasUploadedFile
              ? 'This removes the document metadata and uploaded trip file from this trip.'
              : 'This removes the document reference from this trip.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(tripDocumentActionsProvider).deleteDocument(
          tripId: tripId,
          documentId: document.id,
          document: document,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip document removed.')),
      );
    }
  }

  Future<void> _openDocument(
    BuildContext context,
    WidgetRef ref,
    TripDocument document,
  ) async {
    try {
      await ref
          .read(tripDocumentMutationProvider.notifier)
          .openDocument(document);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(tripDocumentsProvider(tripId));
    final mutation = ref.watch(tripDocumentMutationProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Documents')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDocumentDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          if (mutation?.isLoading == true)
            LinearProgressIndicator(value: mutation?.progress),
          if (mutation?.successMessage != null)
            MaterialBanner(
              content: Text(mutation!.successMessage!),
              actions: [
                TextButton(
                  onPressed: ScaffoldMessenger.of(context).clearMaterialBanners,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          if (mutation?.errorMessage != null)
            MaterialBanner(
              content: Text(mutation!.errorMessage!),
              actions: [
                TextButton(
                  onPressed: ScaffoldMessenger.of(context).clearMaterialBanners,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: documentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Could not load documents: $error')),
              data: (documents) {
                if (documents.isEmpty) {
                  return const Center(
                    child: Text(
                      'No trip documents yet. Add confirmations, tickets, passport or visa references.',
                    ),
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
                        leading: Icon(
                          document.hasUploadedFile
                              ? Icons.file_present_outlined
                              : Icons.description_outlined,
                        ),
                        title: Text(document.title),
                        subtitle: Text(
                          [
                            document.type,
                            if (document.fileName != null) document.fileName!,
                            document.reference,
                            if (document.sizeBytes != null)
                              '${document.sizeBytes} bytes',
                            if (document.notes?.trim().isNotEmpty == true)
                              document.notes!.trim(),
                          ]
                              .where((value) => value.trim().isNotEmpty)
                              .join(' | '),
                        ),
                        onTap: () => _openDocument(context, ref, document),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'open') {
                              await _openDocument(context, ref, document);
                              return;
                            }
                            if (value == 'edit') {
                              await _showDocumentDialog(
                                context,
                                ref,
                                document: document,
                              );
                              return;
                            }
                            await _confirmDelete(context, ref, document);
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'open', child: Text('Open')),
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Remove'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
