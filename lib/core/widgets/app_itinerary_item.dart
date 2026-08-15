import 'package:flutter/material.dart';

import '../../features/trips/models/itinerary/itinerary_item.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

class AppItineraryItem extends StatelessWidget {
  final ItineraryItem item;
  final IconData categoryIcon;
  final String bookedLabel;
  final String editLabel;
  final String deleteLabel;
  final String Function(int minutes) formatMinutes;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AppItineraryItem({
    super.key,
    required this.item,
    required this.categoryIcon,
    required this.bookedLabel,
    required this.editLabel,
    required this.deleteLabel,
    required this.formatMinutes,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              item.time ?? '—',
              textAlign: TextAlign.end,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppCard(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: onOpen,
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadii.medium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(categoryIcon, size: 22, color: colors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: editLabel,
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: deleteLabel,
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          color: colors.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _Metadata(
                          icon: Icons.category_outlined,
                          label: item.category,
                        ),
                        if (item.isBooked)
                          _Metadata(
                            icon: Icons.bookmark_added_outlined,
                            label: bookedLabel,
                            color: colors.secondary,
                          ),
                        if (item.travelMinutesToNext != null)
                          _Metadata(
                            icon: Icons.schedule_outlined,
                            label: formatMinutes(item.travelMinutesToNext!),
                          ),
                        if (item.estimatedCost != null)
                          _Metadata(
                            icon: Icons.payments_outlined,
                            label:
                                '${item.currency} ${item.estimatedCost!.toStringAsFixed(2)}',
                          ),
                      ],
                    ),
                    if (item.location.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              item.location,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        item.notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Metadata extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _Metadata({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = color ?? theme.colorScheme.onSurfaceVariant;

    return Semantics(
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
