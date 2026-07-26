import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.currency,
    required this.budget,
    required this.spent,
  });

  final String currency;
  final double budget;
  final double spent;

  @override
  Widget build(BuildContext context) {
    final remaining = budget - spent;

    return DashboardSection(
      icon: Icons.payments_outlined,
      title: 'Budget',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget: $currency ${budget.toStringAsFixed(2)}'),
          Text('Spent: $currency ${spent.toStringAsFixed(2)}'),
          Text('Remaining: $currency ${remaining.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
