import '../entities/expense.dart';

abstract class ExpenseRepository {
  Stream<List<Expense>> watchExpenses(String tripId);

  Future<void> createExpense(Expense expense);

  Future<void> updateExpense(Expense expense);

  Future<void> deleteExpense({
    required String tripId,
    required String expenseId,
  });
}
