import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/firestore_expense_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return FirestoreExpenseRepository();
});

final tripExpensesProvider = StreamProvider.family<List<Expense>, String>((ref, tripId) {
  return ref.watch(expenseRepositoryProvider).watchExpenses(tripId);
});

class ExpenseMutationNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createExpense({
    required String tripId,
    required String title,
    required double amount,
    required String currency,
    required String category,
    required DateTime spentAt,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final expense = Expense(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      amount: amount,
      currency: currency,
      category: category,
      spentAt: spentAt,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(expenseRepositoryProvider).createExpense(expense),
    );
  }

  Future<void> updateExpense(Expense expense) async {
    final updated = expense.copyWith(updatedAt: DateTime.now());

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(expenseRepositoryProvider).updateExpense(updated),
    );
  }

  Future<void> deleteExpense({
    required String tripId,
    required String expenseId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(expenseRepositoryProvider).deleteExpense(
            tripId: tripId,
            expenseId: expenseId,
          ),
    );
  }
}

final expenseMutationProvider =
    AutoDisposeAsyncNotifierProvider<ExpenseMutationNotifier, void>(
  ExpenseMutationNotifier.new,
);
