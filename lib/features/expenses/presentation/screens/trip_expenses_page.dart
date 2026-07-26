import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_list_item.dart';
import '../../../trips/presentation/providers/trip_dashboard_provider.dart';
import '../../../trips/domain/entities/trip.dart';
import 'add_expense_page.dart';

class TripExpensesPage extends ConsumerStatefulWidget {
  const TripExpensesPage({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  ConsumerState<TripExpensesPage> createState() => _TripExpensesPageState();
}

class _TripExpensesPageState extends ConsumerState<TripExpensesPage> {
  Future<void> _createExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpensePage(
          tripId: widget.trip.id,
          currency: widget.trip.currency,
        ),
      ),
    );
  }

  Future<void> _updateExpense(Expense expense) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpensePage(
          tripId: widget.trip.id,
          currency: widget.trip.currency,
          initialExpense: expense,
        ),
      ),
    );
  }

  Future<void> _deleteExpense(Expense expense) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Delete "${expense.title}" from this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    final notifier = ref.read(expenseMutationProvider.notifier);
    await notifier.deleteExpense(
      tripId: widget.trip.id,
      expenseId: expense.id,
    );
    _showMutationErrorIfAny();
  }

  void _showMutationErrorIfAny() {
    final mutationState = ref.read(expenseMutationProvider);
    if (mutationState.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save expense: ${mutationState.error}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(tripExpensesProvider(widget.trip.id));
    final budgetAsync = ref.watch(tripBudgetProvider(widget.trip.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Expenses'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _ExpenseSummaryCard(
              trip: widget.trip,
              budgetAsync: budgetAsync,
            ),
          ),
          Expanded(
            child: expensesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Unable to load expenses: $error'),
              ),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const Center(
                    child: Text('No expenses yet. Tap Add Expense to start.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ExpenseListItem(
                        expense: expense,
                        onEdit: () => _updateExpense(expense),
                        onDelete: () => _deleteExpense(expense),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({
    required this.trip,
    required this.budgetAsync,
  });

  final Trip trip;
  final AsyncValue<TripBudgetSummary> budgetAsync;

  @override
  Widget build(BuildContext context) {
    final content = budgetAsync.when<Widget>(
      loading: () => const Text('Loading totals...'),
      error: (_, __) => const Text('Unable to calculate totals'),
      data: (summary) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trip Budget: ${summary.currency} ${summary.budget.toStringAsFixed(2)}'),
          Text('Spent: ${summary.currency} ${summary.spent.toStringAsFixed(2)}'),
          Text('Remaining: ${summary.currency} ${summary.remaining.toStringAsFixed(2)}'),
        ],
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.destination,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }
}
