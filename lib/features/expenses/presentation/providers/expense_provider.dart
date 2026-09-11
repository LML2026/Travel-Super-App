import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/domain/entities/auth_user.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/firestore_expense_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../trips/presentation/providers/trip_data_scope_provider.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    return const _UnauthenticatedExpenseRepository();
  }

  return FirestoreExpenseRepository(userId: user.uid);
});

typedef ExpenseRepositoryFactory = ExpenseRepository Function(String userId);

final expenseRepositoryFactoryProvider =
    Provider<ExpenseRepositoryFactory>((ref) {
  return (userId) => FirestoreExpenseRepository(userId: userId);
});

final tripExpensesProvider =
    StreamProvider.family<List<Expense>, String>((ref, tripId) {
  final repository = ref.watch(expenseRepositoryProvider);
  if (repository is! FirestoreExpenseRepository) {
    return repository.watchExpenses(tripId);
  }
  return _scopedExpenseStream(ref, tripId);
});

Stream<List<Expense>> _scopedExpenseStream(Ref ref, String tripId) async* {
  final repository = ref.read(expenseRepositoryProvider);
  AuthUser? user;
  try {
    user = ref.read(immediateCurrentUserProvider);
  } catch (_) {
    yield* repository.watchExpenses(tripId);
    return;
  }
  if (user == null) {
    yield* repository.watchExpenses(tripId);
    return;
  }
  final scope = await ref.watch(tripDataScopeProvider(tripId).future);
  if (scope == null) {
    yield const <Expense>[];
    return;
  }
  yield* ref
      .read(expenseRepositoryFactoryProvider)
      .call(scope.ownerUserId)
      .watchExpenses(tripId);
}

class _UnauthenticatedExpenseRepository implements ExpenseRepository {
  const _UnauthenticatedExpenseRepository();

  @override
  Future<void> createExpense(Expense expense) async {
    throw StateError('Authentication required to manage expenses.');
  }

  @override
  Future<void> deleteExpense({
    required String tripId,
    required String expenseId,
  }) async {
    throw StateError('Authentication required to manage expenses.');
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    throw StateError('Authentication required to manage expenses.');
  }

  @override
  Stream<List<Expense>> watchExpenses(String tripId) {
    return Stream.value(const []);
  }
}

class ExpenseMutationNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ExpenseRepository> _repositoryFor(String tripId) async {
    AuthUser? user;
    try {
      user = ref.read(immediateCurrentUserProvider);
    } catch (_) {
      return ref.read(expenseRepositoryProvider);
    }
    if (user == null) {
      return ref.read(expenseRepositoryProvider);
    }
    TripDataScope? scope;
    try {
      scope = await ref.read(tripDataScopeProvider(tripId).future);
    } catch (_) {
      return ref.read(expenseRepositoryProvider);
    }
    if (scope == null) {
      return ref.read(expenseRepositoryProvider);
    }
    return ref.read(expenseRepositoryFactoryProvider).call(scope.ownerUserId);
  }

  Future<void> createExpense({
    required String tripId,
    required String title,
    required double amount,
    required String currency,
    required String category,
    required DateTime date,
    String notes = '',
  }) async {
    final expense = Expense(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      amount: amount,
      currency: currency,
      category: category,
      date: date,
      notes: notes,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => (await _repositoryFor(tripId)).createExpense(expense),
    );
  }

  Future<void> updateExpense(Expense expense) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => (await _repositoryFor(expense.tripId)).updateExpense(expense),
    );
  }

  Future<void> deleteExpense({
    required String tripId,
    required String expenseId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => (await _repositoryFor(tripId)).deleteExpense(
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
