import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppJourneyConnector extends StatelessWidget {
  final int? durationMinutes;
  final int? distanceMetres;
  final String? travelModeLabel;
  final String Function(int minutes) formatMinutes;
  final String Function(int metres) formatDistance;

  const AppJourneyConnector({
    super.key,
    required this.durationMinutes,
    required this.distanceMetres,
    required this.travelModeLabel,
    required this.formatMinutes,
    required this.formatDistance,
  });

  @override
  Widget build(BuildContext context) {
    final hasRouteHint = durationMinutes != null || distanceMetres != null;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final details = <String>[
      if (durationMinutes != null) formatMinutes(durationMinutes!),
      if (distanceMetres != null) formatDistance(distanceMetres!),
      ?travelModeLabel,
    ];

    return Semantics(
      label: details.join(' · '),
      child: SizedBox(
        height: hasRouteHint ? 48 : 24,
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Center(
                child: Container(width: 2, color: colors.outlineVariant),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.route_outlined,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  if (hasRouteHint) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        details.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
