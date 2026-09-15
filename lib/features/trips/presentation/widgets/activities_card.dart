import 'package:flutter/material.dart';

import '../providers/trip_activity_provider.dart';
import 'dashboard_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/user_facing_error.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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
        loading: () => Text(context.ui('loadingActivities')),
        error: (error, _) => Text(UserFacingError.message(
          error,
          fallback: 'Activities are unavailable right now.',
        )),
        data: (activities) {
          if (activities.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.ui('noActivitiesPlanned'),
                    style: AppTextStyles.bodyMuted),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: onOpenActivities,
                  icon: const Icon(Icons.add),
                  label: Text(context.ui('addActivity')),
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
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      '• ${activity.title} | $location | $schedule',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textNavy,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xs),
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
