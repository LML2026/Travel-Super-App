import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

class AppTripCard extends StatelessWidget {
  final String destination;
  final String dates;
  final String details;
  final VoidCallback onTap;

  const AppTripCard({
    super.key,
    required this.destination,
    required this.dates,
    required this.details,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      label: '$destination. $dates. $details',
      child: AppCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadii.medium),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadii.small),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.flight_takeoff,
                      color: colors.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(dates, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(details, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right, color: colors.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
