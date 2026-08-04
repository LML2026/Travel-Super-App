import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({
    super.key,
    required this.tripId,
    required this.currency,
    this.initialExpense,
  });

  final String tripId;
  final String currency;
  final Expense? initialExpense;

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  static const List<String> _categories = <String>[
    '🍽 Food',
    '🚕 Transport',
    '🏨 Accommodation',
    '✈ Flights',
    '☕ Coffee',
    '🎟 Entertainment',
    '🛍 Shopping',
    '🏥 Medical',
    '📱 Mobile',
    '📦 Other',
  ];

  late String _currency;
  String? _category;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    final existing = widget.initialExpense;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toStringAsFixed(2),
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _currency = existing?.currency ?? widget.currency;
    _category = existing?.category;
    _date = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;
    setState(() {
      _date = picked;
    });
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_date == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Date is required.')));
      return;
    }

    if (_category == null || _category!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category must be selected.')),
      );
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final notifier = ref.read(expenseMutationProvider.notifier);

    if (widget.initialExpense == null) {
      await notifier.createExpense(
        tripId: widget.tripId,
        title: _titleController.text.trim(),
        amount: amount,
        currency: _currency,
        category: _category!,
        date: _date!,
        notes: _notesController.text.trim(),
      );
    } else {
      await notifier.updateExpense(
        widget.initialExpense!.copyWith(
          title: _titleController.text.trim(),
          amount: amount,
          currency: _currency,
          category: _category!,
          date: _date!,
          notes: _notesController.text.trim(),
        ),
      );
    }

    final mutationState = ref.read(expenseMutationProvider);
    if (mutationState.hasError) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save expense: ${mutationState.error}'),
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExpense != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Expense' : 'Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Expense Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount (£)',
                hintText: _currency,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required.';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Amount must be greater than £0.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(labelText: 'Currency'),
              items: const [
                DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _currency = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _category = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Category must be selected.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(
                _date == null
                    ? 'Select date'
                    : '${_date!.day.toString().padLeft(2, '0')} '
                          '${_monthName(_date!.month)} ${_date!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saveExpense,
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}
