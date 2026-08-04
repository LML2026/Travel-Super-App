import 'dart:async';

import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';

class InMemoryWalletRepository implements WalletRepository {
  InMemoryWalletRepository({this.defaultBaseCurrency = 'GBP'});

  final String defaultBaseCurrency;
  final Map<String, Wallet> _walletsByUser = {};
  final Map<String, List<WalletTransaction>> _transactionsByUser = {};
  final Map<String, StreamController<Wallet>> _walletControllersByUser = {};
  final Map<String, StreamController<List<WalletTransaction>>>
  _transactionControllersByUser = {};

  String _walletIdFor(String userId) => 'wallet-$userId';

  String _resolveUserIdFromWalletId(String walletId) {
    if (walletId.startsWith('wallet-') && walletId.length > 'wallet-'.length) {
      return walletId.substring('wallet-'.length);
    }
    return walletId;
  }

  Wallet _walletForUser(String userId) {
    return _walletsByUser.putIfAbsent(
      userId,
      () => Wallet(
        id: _walletIdFor(userId),
        userId: userId,
        baseCurrency: defaultBaseCurrency,
        balances: {defaultBaseCurrency: 1000, 'EUR': 500, 'USD': 250},
      ),
    );
  }

  List<WalletTransaction> _transactionsForUser(String userId) {
    return _transactionsByUser.putIfAbsent(userId, () => <WalletTransaction>[]);
  }

  StreamController<Wallet> _walletControllerForUser(String userId) {
    return _walletControllersByUser.putIfAbsent(
      userId,
      () => StreamController<Wallet>.broadcast(),
    );
  }

  StreamController<List<WalletTransaction>> _transactionControllerForUser(
    String userId,
  ) {
    return _transactionControllersByUser.putIfAbsent(
      userId,
      () => StreamController<List<WalletTransaction>>.broadcast(),
    );
  }

  void _emitUserState(String userId) {
    _walletControllerForUser(userId).add(_walletForUser(userId));
    _transactionControllerForUser(
      userId,
    ).add(List.unmodifiable(_transactionsForUser(userId)));
  }

  @override
  Stream<Wallet> watchWallet(String userId) {
    _emitUserState(userId);
    return _walletControllerForUser(userId).stream;
  }

  @override
  Stream<List<WalletTransaction>> watchTransactions(String walletId) {
    final userId = _resolveUserIdFromWalletId(walletId);
    _emitUserState(userId);
    return _transactionControllerForUser(userId).stream;
  }

  @override
  Future<Wallet?> getWallet(String userId) async => _walletForUser(userId);

  @override
  Future<void> addCurrency({
    required String walletId,
    required String currency,
  }) async {
    final userId = _resolveUserIdFromWalletId(walletId);
    final wallet = _walletForUser(userId);

    final balances = Map<String, double>.from(wallet.balances);
    balances.putIfAbsent(currency, () => 0);
    _walletsByUser[userId] = wallet.copyWith(balances: balances);

    _emitUserState(userId);
  }

  @override
  Future<void> deposit({
    required String walletId,
    required double amount,
    required String currency,
  }) async {
    final userId = _resolveUserIdFromWalletId(walletId);
    final wallet = _walletForUser(userId);
    final transactions = _transactionsForUser(userId);

    final balances = Map<String, double>.from(wallet.balances);
    balances[currency] = (balances[currency] ?? 0) + amount;
    _walletsByUser[userId] = wallet.copyWith(balances: balances);

    transactions.insert(
      0,
      WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        walletId: walletId,
        type: WalletTransactionType.deposit,
        status: WalletTransactionStatus.completed,
        amount: amount,
        currency: currency,
        createdAt: DateTime.now(),
        description: 'Wallet deposit',
      ),
    );

    _emitUserState(userId);
  }

  @override
  Future<void> transfer({
    required String sourceWalletId,
    required String destinationWalletId,
    required double amount,
    required String currency,
  }) async {
    final userId = _resolveUserIdFromWalletId(sourceWalletId);
    final wallet = _walletForUser(userId);
    final transactions = _transactionsForUser(userId);

    final balances = Map<String, double>.from(wallet.balances);
    final current = balances[currency] ?? 0;
    if (current < amount) {
      throw Exception('Insufficient funds');
    }

    balances[currency] = current - amount;
    _walletsByUser[userId] = wallet.copyWith(balances: balances);

    transactions.insert(
      0,
      WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        walletId: sourceWalletId,
        type: WalletTransactionType.transferOut,
        status: WalletTransactionStatus.completed,
        amount: amount,
        currency: currency,
        recipientWalletId: destinationWalletId,
        createdAt: DateTime.now(),
        description: 'Transfer',
      ),
    );

    _emitUserState(userId);
  }

  @override
  Future<void> convertCurrency({
    required String walletId,
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required double exchangeRate,
  }) async {
    final userId = _resolveUserIdFromWalletId(walletId);
    final wallet = _walletForUser(userId);
    final transactions = _transactionsForUser(userId);

    final balances = Map<String, double>.from(wallet.balances);
    if ((balances[fromCurrency] ?? 0) < amount) {
      throw Exception('Insufficient funds');
    }

    balances[fromCurrency] = (balances[fromCurrency] ?? 0) - amount;
    final converted = amount * exchangeRate;
    balances[toCurrency] = (balances[toCurrency] ?? 0) + converted;
    _walletsByUser[userId] = wallet.copyWith(balances: balances);

    transactions.insert(
      0,
      WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        walletId: walletId,
        type: WalletTransactionType.currencyConversion,
        status: WalletTransactionStatus.completed,
        amount: amount,
        currency: fromCurrency,
        convertedAmount: converted,
        convertedCurrency: toCurrency,
        exchangeRate: exchangeRate,
        createdAt: DateTime.now(),
        description: 'Currency exchange',
      ),
    );

    _emitUserState(userId);
  }
}
