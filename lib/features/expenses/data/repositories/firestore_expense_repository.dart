import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';

class FirestoreExpenseRepository implements ExpenseRepository {
  FirestoreExpenseRepository({
    FirebaseFirestore? firestore,
    required String userId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userId = userId;

  final FirebaseFirestore _firestore;
  final String _userId;

  CollectionReference<Map<String, dynamic>> _expenseCollection(String tripId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('trips')
        .doc(tripId)
        .collection('expenses');
  }

  @override
  Stream<List<Expense>> watchExpenses(String tripId) {
    return _expenseCollection(tripId)
      .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> createExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _expenseCollection(expense.tripId)
        .doc(expense.id)
        .set(model.toFirestore());
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _expenseCollection(expense.tripId)
        .doc(expense.id)
        .update(model.toFirestore());
  }

  @override
  Future<void> deleteExpense({
    required String tripId,
    required String expenseId,
  }) async {
    await _expenseCollection(tripId).doc(expenseId).delete();
  }
}
