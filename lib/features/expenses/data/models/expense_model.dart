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
    required super.spentAt,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      tripId: expense.tripId,
      title: expense.title,
      amount: expense.amount,
      currency: expense.currency,
      category: expense.category,
      spentAt: expense.spentAt,
      notes: expense.notes,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }

  factory ExpenseModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return ExpenseModel(
      id: doc.id,
      tripId: data['tripId'] as String,
      title: data['title'] as String,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String,
      category: data['category'] as String,
      spentAt: (data['spentAt'] as Timestamp).toDate(),
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category,
      'spentAt': Timestamp.fromDate(spentAt),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
