import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/trip_dashboard_provider.dart';
import 'dashboard_section.dart';

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
      loading: () => const Text('Loading budget...'),
      error: (_, __) => const Text('Unable to load budget'),
      data: (summary) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Trip Budget: ${summary.currency} ${summary.budget.toStringAsFixed(2)}'),
          Text(
              'Spent: ${summary.currency} ${summary.spent.toStringAsFixed(2)}'),
          Text(
              'Remaining: ${summary.currency} ${summary.remaining.toStringAsFixed(2)}'),
        ],
      ),
    );

    return DashboardSection(
      icon: Icons.payments_outlined,
      title: 'Budget',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      ),
    );
  }
}
