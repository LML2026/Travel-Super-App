import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_card.dart';

class AppAttentionCard extends StatelessWidget {
  final String title;
  final String detail;
  final String actionLabel;
  final VoidCallback onAction;

  const AppAttentionCard({
    super.key,
    required this.title,
    required this.detail,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      liveRegion: true,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: colors.secondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(detail, style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.map_outlined),
                    label: Text(actionLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
