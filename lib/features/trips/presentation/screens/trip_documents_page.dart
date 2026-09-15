import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trip_document.dart';
import '../../domain/entities/trip_document_upload.dart';
import '../providers/trip_document_provider.dart';
import '../../../../core/utils/user_facing_error.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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
                      decoration: InputDecoration(labelText: context.ui('title')),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: typeController,
                      decoration: InputDecoration(
                        labelText: context.ui('type'),
                        hintText: context.ui('documentTypeHint'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: referenceController,
                      decoration: InputDecoration(
                        labelText: context.ui('referenceUrlCode'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(labelText: context.ui('notes')),
                    ),
                    if (!isEditing) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: filePathController,
                        decoration: InputDecoration(
                          labelText: context.ui('localFilePath'),
                          hintText: context.ui('confirmationPdfPath'),
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
                                uploadError = UserFacingError.message(
                                  error,
                                  fallback: 'We could not read that file.',
                                );
                                upload = null;
                              });
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                          label: Text(context.ui('attachFile')),
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
                  child: Text(context.ui('cancel')),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final type = typeController.text.trim();
                    final reference = referenceController.text.trim();
                    if (title.isEmpty || type.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.ui('titleAndTypeRequired')),
                        ),
                      );
                      return;
                    }
                    if (reference.isEmpty && upload == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Add a reference, URL, code, or uploaded file.',
                          ),
                        ),
                      );
                      return;
                    }

                    final notes = notesController.text.trim();
                    try {
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
                    } catch (error) {
                      setDialogState(() {
                        uploadError = UserFacingError.message(
                          error,
                          fallback:
                              'File upload is unavailable right now. You can add this document as a reference instead.',
                        );
                      });
                      return;
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
        title: Text(context.ui('removeDocumentQuestion')),
        content: Text(
          document.hasUploadedFile
              ? 'This removes the document metadata and uploaded trip file from this trip.'
              : 'This removes the document reference from this trip.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.ui('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.ui('remove')),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(tripDocumentActionsProvider).deleteDocument(
            tripId: tripId,
            documentId: document.id,
            document: document,
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(UserFacingError.message(
              error,
              fallback: 'We could not remove this document right now.',
            )),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.ui('tripDocumentRemoved'))),
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
          SnackBar(
            content: Text(UserFacingError.message(
              error,
              fallback: 'We could not update this document.',
            )),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(tripDocumentsProvider(tripId));
    final mutation = ref.watch(tripDocumentMutationProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(context.ui('tripDocuments'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDocumentDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(context.ui('add')),
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
                  child: Text(context.ui('dismiss')),
                ),
              ],
            ),
          if (mutation?.errorMessage != null)
            MaterialBanner(
              content: Text(mutation!.errorMessage!),
              actions: [
                TextButton(
                  onPressed: ScaffoldMessenger.of(context).clearMaterialBanners,
                  child: Text(context.ui('dismiss')),
                ),
              ],
            ),
          Expanded(
            child: documentsAsync.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(UserFacingError.message(
                  error,
                  fallback: 'Documents are unavailable right now.',
                )),
              ),
              data: (documents) {
                if (documents.isEmpty) {
                  return Center(
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
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'open', child: Text(context.ui('open'))),
                            PopupMenuItem(value: 'edit', child: Text(context.ui('edit'))),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(context.ui('remove')),
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
