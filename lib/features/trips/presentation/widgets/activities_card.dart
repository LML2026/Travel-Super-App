import 'package:flutter/material.dart';

import '../providers/trip_activity_provider.dart';
import 'dashboard_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ActivitiesCard extends ConsumerWidget {
  const ActivitiesCard({
    super.key,
    required this.tripId,
    this.onOpenActivities,
  });

  final String tripId;
  final VoidCallback? onOpenActivities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(tripActivitiesProvider(tripId));

    return DashboardSection(
      icon: Icons.event_note,
      title: 'Activities',
      child: activitiesAsync.when(
        loading: () => const Text('Loading activities...'),
        error: (error, _) => Text('Could not load activities: $error'),
        data: (activities) {
          if (activities.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('No activities planned yet.'),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onOpenActivities,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Activity'),
                ),
              ],
            );
          }

          final items = activities.take(3).toList(growable: false);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...items.map(
                (activity) {
                  final schedule = activity.scheduledAt == null
                      ? 'Unscheduled'
                      : DateFormat('dd MMM, HH:mm')
                          .format(activity.scheduledAt!);
                  final location = activity.location?.trim().isNotEmpty == true
                      ? activity.location!.trim()
                      : 'No location';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• ${activity.title} | $location | $schedule'),
                  );
                },
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: onOpenActivities,
                child: Text(
                  activities.length > 3
                      ? 'View all (${activities.length})'
                      : 'Manage activities',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
