import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

class AppFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool available;

  const AppFeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.available = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isInteractive = available && onTap != null;
    final iconColor = isInteractive ? colorScheme.primary : colorScheme.outline;
    final titleColor = isInteractive
        ? colorScheme.onSurface
        : colorScheme.onSurface.withAlpha(150);

    return Semantics(
      button: isInteractive,
      enabled: isInteractive,
      label: '$title. $subtitle',
      child: AppCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: isInteractive ? onTap : null,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadii.medium),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 140;
                final iconSurface = DecoratedBox(
                  decoration: BoxDecoration(
                    color: isInteractive
                        ? colorScheme.secondaryContainer
                        : AppColors.lightSurfaceVariant.withAlpha(150),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadii.small),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      compact ? AppSpacing.xs : AppSpacing.sm,
                    ),
                    child: Icon(
                      icon,
                      size: compact ? 20 : 24,
                      color: iconColor,
                    ),
                  ),
                );
                final text = Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: compact ? 2 : AppSpacing.xs),
                      Text(
                        subtitle,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                );

                if (compact) {
                  return Row(
                    children: [
                      iconSurface,
                      const SizedBox(width: AppSpacing.sm),
                      text,
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        isInteractive
                            ? Icons.arrow_forward_rounded
                            : Icons.lock_outline,
                        size: 18,
                        color: iconColor,
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconSurface,
                    const Spacer(),
                    text,
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Icon(
                        isInteractive
                            ? Icons.arrow_forward_rounded
                            : Icons.lock_outline,
                        size: 18,
                        color: iconColor,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
