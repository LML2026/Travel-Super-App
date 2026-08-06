import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/trip_activity_provider.dart';

class TripActivitiesPage extends ConsumerWidget {
  const TripActivitiesPage({
    super.key,
    required this.tripId,
  });

  final String tripId;

  Future<void> _showAddActivityDialog(
      BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final dateController = TextEditingController();
    final notesController = TextEditingController();

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Activity'),
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
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Schedule (yyyy-mm-dd hh:mm, optional)',
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
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title is required.')),
                  );
                  return;
                }

                final rawDate = dateController.text.trim();
                final parsedDate =
                    rawDate.isEmpty ? null : DateTime.tryParse(rawDate);
                if (rawDate.isNotEmpty && parsedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Invalid date format. Use yyyy-mm-dd hh:mm'),
                    ),
                  );
                  return;
                }

                await ref.read(tripActivityActionsProvider).addActivity(
                      tripId: tripId,
                      title: title,
                      location: locationController.text.trim().isEmpty
                          ? null
                          : locationController.text.trim(),
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                      scheduledAt: parsedDate,
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
    locationController.dispose();
    dateController.dispose();
    notesController.dispose();

    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip activity added.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(tripActivitiesProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Activities')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActivityDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: activitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load activities: $error')),
        data: (activities) {
          if (activities.isEmpty) {
            return const Center(
              child: Text('No activities yet. Add your first trip plan.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final activity = activities[index];
              final scheduledText = activity.scheduledAt == null
                  ? 'Unscheduled'
                  : DateFormat('dd MMM, HH:mm').format(activity.scheduledAt!);

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.explore_outlined),
                  title: Text(activity.title),
                  subtitle: Text(
                    '${activity.location ?? 'No location'} | $scheduledText',
                  ),
                  trailing: IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref
                          .read(tripActivityActionsProvider)
                          .deleteActivity(
                            tripId: tripId,
                            activityId: activity.id,
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
