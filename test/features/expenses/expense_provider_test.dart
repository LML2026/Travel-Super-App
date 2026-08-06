import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/expenses/domain/entities/expense.dart';
import 'package:travel_super_app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:travel_super_app/features/expenses/presentation/providers/expense_provider.dart';

class _FakeExpenseRepository implements ExpenseRepository {
  final StreamController<List<Expense>> controller =
      StreamController<List<Expense>>.broadcast();

  final List<Expense> created = <Expense>[];
  final List<Expense> updated = <Expense>[];
  final List<String> deleted = <String>[];

  @override
  Future<void> createExpense(Expense expense) async {
    created.add(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    updated.add(expense);
  }

  @override
  Future<void> deleteExpense({
    required String tripId,
    required String expenseId,
  }) async {
    deleted.add('$tripId:$expenseId');
  }

  @override
  Stream<List<Expense>> watchExpenses(String tripId) {
    return controller.stream;
  }
}

Expense _expense({String id = 'expense-1', String tripId = 'trip-1'}) {
  return Expense(
    id: id,
    tripId: tripId,
    title: 'Lunch',
    amount: 24.5,
    currency: 'GBP',
    category: 'Food',
    date: DateTime(2026, 7, 26),
    notes: '',
  );
}

void main() {
  test('tripExpensesProvider streams expenses for trip', () async {
    final fakeRepo = _FakeExpenseRepository();
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(() async {
      await fakeRepo.controller.close();
      container.dispose();
    });

    final future = container.read(tripExpensesProvider('trip-1').future);
    fakeRepo.controller.add(<Expense>[_expense()]);

    final values = await future;
    expect(values, hasLength(1));
    expect(values.first.title, 'Lunch');
  });

  test('expenseMutationProvider delegates create/update/delete', () async {
    final fakeRepo = _FakeExpenseRepository();
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(() async {
      await fakeRepo.controller.close();
      container.dispose();
    });

    final notifier = container.read(expenseMutationProvider.notifier);

    await notifier.createExpense(
      tripId: 'trip-1',
      title: 'Taxi',
      amount: 30,
      currency: 'GBP',
      category: 'Transport',
      date: DateTime(2026, 7, 25),
      notes: 'Airport to hotel',
    );

    await notifier.updateExpense(_expense());

    await notifier.deleteExpense(
      tripId: 'trip-1',
      expenseId: 'expense-1',
    );

    expect(fakeRepo.created, hasLength(1));
    expect(fakeRepo.created.single.title, 'Taxi');
    expect(fakeRepo.updated, hasLength(1));
    expect(fakeRepo.deleted, <String>['trip-1:expense-1']);
  });
}
