import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_card.dart';

class AppJourneyBriefLine {
  final IconData icon;
  final String label;
  final String value;

  const AppJourneyBriefLine({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class AppJourneyBrief extends StatelessWidget {
  final String title;
  final List<AppJourneyBriefLine> lines;

  const AppJourneyBrief({super.key, required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < lines.length; index++) ...[
            if (index > 0) const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(lines[index].icon, size: 20, color: colors.secondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${lines[index].label}: ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: lines[index].value),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
