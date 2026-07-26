import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../models/trip.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
  });

  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.destination,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${DateFormat('dd MMM yyyy').format(trip.startDate)} → ${DateFormat('dd MMM yyyy').format(trip.endDate)}',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Budget ${_currencySymbol(trip.currency)}${NumberFormat('#,##0').format(trip.budget)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${trip.travellers} ${trip.travellers == 1 ? 'Traveller' : 'Travellers'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Text(
                'View itinerary →',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (onEdit != null || onDuplicate != null || onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    }
                    if (value == 'duplicate') {
                      onDuplicate?.call();
                    }
                    if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                    if (onDuplicate != null)
                      const PopupMenuItem<String>(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'USD':
        return r'$';
      default:
        return '$currency ';
    }
  }
}
