import 'package:flutter/material.dart';

import '../../domain/entities/expense.dart';

class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: Text(
        _categoryEmoji(expense.category),
        style: const TextStyle(fontSize: 22),
      ),
      title: Text(
        expense.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${expense.currency} ${expense.amount.toStringAsFixed(2)}'),
          Text(
            '${expense.date.day.toString().padLeft(2, '0')} ${_monthName(expense.date.month)} ${expense.date.year}',
          ),
          if (expense.notes.isNotEmpty) Text(expense.notes),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            onEdit();
          }
          if (value == 'delete') {
            onDelete();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
          PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: onEdit,
    );
  }

  String _categoryEmoji(String category) {
    final parts = category.trim().split(' ');
    if (parts.isNotEmpty && parts.first.runes.length <= 2) {
      return parts.first;
    }
    return '📦';
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
