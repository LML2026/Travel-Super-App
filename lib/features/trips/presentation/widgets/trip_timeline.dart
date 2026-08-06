import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class TripTimeline extends StatelessWidget {
  const TripTimeline({
    super.key,
    required this.entries,
  });

  final List<TripTimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (entry != entries.last)
                        Container(
                          width: 2,
                          height: 42,
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.dateLabel,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (entry.subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(entry.subtitle!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class TripTimelineEntry {
  const TripTimelineEntry({
    required this.dateLabel,
    required this.title,
    this.subtitle,
  });

  final String dateLabel;
  final String title;
  final String? subtitle;
}
