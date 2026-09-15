import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/trip_dashboard_provider.dart';
import 'dashboard_section.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({
    super.key,
    required this.tripId,
    this.onTap,
  });

  final String tripId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(tripBudgetProvider(tripId));

    final content = budgetAsync.when<Widget>(
      loading: () => Text(context.ui('loadingBudget')),
      error: (_, __) => Text(context.ui('unableLoadBudget')),
      data: (summary) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Budget: ${summary.currency} ${summary.budget.toStringAsFixed(2)}',
            style: AppTextStyles.body.copyWith(color: AppColors.textNavy),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Spent: ${summary.currency} ${summary.spent.toStringAsFixed(2)}',
            style: AppTextStyles.bodyMuted,
          ),
          Text(
            'Remaining: ${summary.currency} ${summary.remaining.toStringAsFixed(2)}',
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );

    return DashboardSection(
      icon: Icons.payments_outlined,
      title: 'Budget',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: content,
        ),
      ),
    );
  }
}
