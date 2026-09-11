import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/user_facing_error.dart';

import '../../domain/entities/trip_activity.dart';
import '../providers/trip_activity_provider.dart';

class TripActivitiesPage extends ConsumerWidget {
  const TripActivitiesPage({
    super.key,
    required this.tripId,
  });

  final String tripId;

  Future<void> _showActivityDialog(
    BuildContext context,
    WidgetRef ref, {
    TripActivity? activity,
  }) async {
    final titleController = TextEditingController(text: activity?.title);
    final locationController = TextEditingController(text: activity?.location);
    final dateController = TextEditingController(
      text: activity?.scheduledAt == null
          ? ''
          : DateFormat('yyyy-MM-dd HH:mm').format(activity!.scheduledAt!),
    );
    final costController = TextEditingController(
      text: activity?.cost == null ? '' : activity!.cost!.toStringAsFixed(2),
    );
    final currencyController =
        TextEditingController(text: activity?.currency ?? 'GBP');
    final statusController =
        TextEditingController(text: activity?.status ?? 'Planned');
    final notesController = TextEditingController(text: activity?.notes);
    final isEditing = activity != null;

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Activity' : 'Add Activity'),
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
                    labelText: 'Date and time',
                    hintText: '2026-08-25 14:30',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: costController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cost',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 88,
                      child: TextField(
                        controller: currencyController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: statusController,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    hintText: 'Planned, booked, optional',
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
                final parsedDate = rawDate.isEmpty
                    ? null
                    : DateTime.tryParse(rawDate.replaceFirst(' ', 'T'));
                if (rawDate.isNotEmpty && parsedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid date format. Use yyyy-mm-dd hh:mm'),
                    ),
                  );
                  return;
                }

                final rawCost = costController.text.trim();
                final cost =
                    rawCost.isEmpty ? null : double.tryParse(rawCost);
                if (rawCost.isNotEmpty && cost == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid cost.')),
                  );
                  return;
                }

                final location = locationController.text.trim();
                final notes = notesController.text.trim();
                final currency = currencyController.text.trim().toUpperCase();
                final status = statusController.text.trim();

                if (isEditing) {
                  await ref.read(tripActivityActionsProvider).updateActivity(
                        activity.copyWith(
                          title: title,
                          location: location.isEmpty ? null : location,
                          notes: notes.isEmpty ? null : notes,
                          scheduledAt: parsedDate,
                          cost: cost,
                          currency: currency.isEmpty ? 'GBP' : currency,
                          status: status.isEmpty ? 'Planned' : status,
                        ),
                      );
                } else {
                  await ref.read(tripActivityActionsProvider).addActivity(
                        tripId: tripId,
                        title: title,
                        location: location.isEmpty ? null : location,
                        notes: notes.isEmpty ? null : notes,
                        scheduledAt: parsedDate,
                        cost: cost,
                        currency: currency.isEmpty ? 'GBP' : currency,
                        status: status.isEmpty ? 'Planned' : status,
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
    locationController.dispose();
    dateController.dispose();
    costController.dispose();
    currencyController.dispose();
    statusController.dispose();
    notesController.dispose();

    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Trip activity updated.' : 'Trip activity added.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(tripActivitiesProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Activities')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActivityDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: activitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(UserFacingError.message(
            error,
            fallback: 'Activities are unavailable right now.',
          )),
        ),
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
              final costText = activity.cost == null
                  ? 'No cost'
                  : '${activity.currency ?? 'GBP'} ${activity.cost!.toStringAsFixed(2)}';
              final status = activity.status?.trim().isNotEmpty == true
                  ? activity.status!.trim()
                  : 'Planned';

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.explore_outlined),
                  title: Text(activity.title),
                  subtitle: Text(
                    '${activity.location ?? 'No location'} | $scheduledText | $costText | $status',
                  ),
                  onTap: () => _showActivityDialog(
                    context,
                    ref,
                    activity: activity,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await _showActivityDialog(
                          context,
                          ref,
                          activity: activity,
                        );
                        return;
                      }

                      await ref.read(tripActivityActionsProvider).deleteActivity(
                            tripId: tripId,
                            activityId: activity.id,
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
