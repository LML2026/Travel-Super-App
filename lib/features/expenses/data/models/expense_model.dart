import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.tripId,
    required super.title,
    required super.amount,
    required super.currency,
    required super.category,
    required super.date,
    required super.notes,
  });

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      tripId: expense.tripId,
      title: expense.title,
      amount: expense.amount,
      currency: expense.currency,
      category: expense.category,
      date: expense.date,
      notes: expense.notes,
    );
  }

  factory ExpenseModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return ExpenseModel(
      id: doc.id,
      tripId: data['tripId'] as String,
      title: data['title'] as String,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String,
      category: data['category'] as String,
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': Timestamp.fromDate(date),
      'notes': notes,
    };
  }
}
