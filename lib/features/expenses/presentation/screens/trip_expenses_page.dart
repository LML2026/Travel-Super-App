import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_list_item.dart';
import '../../../trips/presentation/providers/trip_dashboard_provider.dart';
import '../../../trips/domain/entities/trip.dart';
import 'add_expense_page.dart';
import '../../../../core/utils/user_facing_error.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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
        title: Text(context.ui('deleteExpenseQuestion')),
        content: Text('${context.ui('delete')} "${expense.title}" ${context.ui('fromThisTripQuestion')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.ui('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.ui('delete')),
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
          content: Text(UserFacingError.message(
            mutationState.error!,
            fallback: 'We could not save this expense.',
          )),
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
        title: Text(context.ui('tripExpenses')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createExpense,
        icon: const Icon(Icons.add),
        label: Text(context.ui('addExpense')),
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
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(UserFacingError.message(
                  error,
                  fallback: 'Expenses are unavailable right now.',
                )),
              ),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return Center(
                    child: Text(context.ui('noExpensesYet')),
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
      loading: () => Text(context.ui('loadingTotals')),
      error: (_, __) => Text(context.ui('unableCalculateTotals')),
      data: (summary) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${context.ui('tripBudget')}: ${summary.currency} ${summary.budget.toStringAsFixed(2)}'),
          Text('${context.ui('spent')}: ${summary.currency} ${summary.spent.toStringAsFixed(2)}'),
          Text('${context.ui('remaining')}: ${summary.currency} ${summary.remaining.toStringAsFixed(2)}'),
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
