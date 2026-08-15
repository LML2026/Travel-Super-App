import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_card.dart';

class AppMetricTile extends StatelessWidget {
  final String label;
  final String value;

  const AppMetricTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
