import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../../../trips/presentation/providers/trip_dashboard_provider.dart';
import '../../../trips/domain/entities/trip.dart';

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
  static const List<String> _categories = <String>[
    'Transport',
    'Accommodation',
    'Food',
    'Activities',
    'Shopping',
    'Other',
  ];

  Future<void> _createExpense() async {
    final input = await _showExpenseDialog();
    if (input == null) {
      return;
    }

    final notifier = ref.read(expenseMutationProvider.notifier);
    await notifier.createExpense(
      tripId: widget.trip.id,
      title: input.title,
      amount: input.amount,
      currency: widget.trip.currency,
      category: input.category,
      spentAt: input.spentAt,
      notes: input.notes,
    );
    _showMutationErrorIfAny();
  }

  Future<void> _updateExpense(Expense expense) async {
    final input = await _showExpenseDialog(existing: expense);
    if (input == null) {
      return;
    }

    final notifier = ref.read(expenseMutationProvider.notifier);
    await notifier.updateExpense(
      expense.copyWith(
        title: input.title,
        amount: input.amount,
        category: input.category,
        spentAt: input.spentAt,
        notes: input.notes,
        updatedAt: DateTime.now(),
      ),
    );
    _showMutationErrorIfAny();
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

  Future<_ExpenseInput?> _showExpenseDialog({Expense? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toStringAsFixed(2),
    );
    final notesController = TextEditingController(text: existing?.notes ?? '');
    var selectedCategory = existing?.category ?? _categories.first;
    var selectedDate = existing?.spentAt ?? DateTime.now();

    final result = await showDialog<_ExpenseInput>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(existing == null ? 'Add Expense' : 'Edit Expense'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Taxi, Lunch, Museum tickets...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (${widget.trip.currency})',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    items: _categories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Spent At'),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked == null) return;
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final parsedAmount = double.tryParse(amountController.text.trim());

                  if (title.isEmpty || parsedAmount == null || parsedAmount <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Enter a valid title and amount.'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    _ExpenseInput(
                      title: title,
                      amount: parsedAmount,
                      category: selectedCategory,
                      spentAt: selectedDate,
                      notes: notesController.text.trim(),
                    ),
                  );
                },
                child: Text(existing == null ? 'Add' : 'Save'),
              ),
            ],
          ),
        );
      },
    );

    titleController.dispose();
    amountController.dispose();
    notesController.dispose();

    return result;
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
                    final formattedDate = DateFormat('dd MMM yyyy').format(expense.spentAt);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(expense.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${expense.category} • $formattedDate'),
                            Text('${expense.currency} ${expense.amount.toStringAsFixed(2)}'),
                            if (expense.notes.isNotEmpty) Text(expense.notes),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _updateExpense(expense);
                            }
                            if (value == 'delete') {
                              _deleteExpense(expense);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                        leading: CircleAvatar(
                          child: Text(expense.category.characters.first.toUpperCase()),
                        ),
                        dense: false,
                        isThreeLine: expense.notes.isNotEmpty,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minVerticalPadding: 10,
                        horizontalTitleGap: 12,
                        visualDensity: VisualDensity.standard,
                        titleAlignment: ListTileTitleAlignment.top,
                        onTap: () => _updateExpense(expense),
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

class _ExpenseInput {
  const _ExpenseInput({
    required this.title,
    required this.amount,
    required this.category,
    required this.spentAt,
    required this.notes,
  });

  final String title;
  final double amount;
  final String category;
  final DateTime spentAt;
  final String notes;
}
