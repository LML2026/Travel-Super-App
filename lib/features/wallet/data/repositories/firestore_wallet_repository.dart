import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';

class FirestoreWalletRepository implements WalletRepository {
  FirestoreWalletRepository({
    FirebaseFirestore? firestore,
    required String userId,
    this.defaultBaseCurrency = 'GBP',
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userId = userId;

  final FirebaseFirestore _firestore;
  final String _userId;
  final String defaultBaseCurrency;

  String _walletIdFor(String userId) => 'wallet-$userId';

  String _resolveUserIdFromWalletId(String walletId) {
    if (walletId.startsWith('wallet-') && walletId.length > 'wallet-'.length) {
      return walletId.substring('wallet-'.length);
    }
    return walletId;
  }

  void _assertUserScope(String userId) {
    if (userId != _userId) {
      throw StateError('Wallet access is not permitted for this user scope.');
    }
  }

  Wallet _defaultWallet(String userId) {
    return Wallet(
      id: _walletIdFor(userId),
      userId: userId,
      baseCurrency: defaultBaseCurrency,
      balances: {
        defaultBaseCurrency: 1000,
        'EUR': 500,
        'USD': 250,
      },
    );
  }

  DocumentReference<Map<String, dynamic>> _walletDoc(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .doc(_walletIdFor(userId));
  }

  CollectionReference<Map<String, dynamic>> _transactionsCollection(
      String userId) {
    return _walletDoc(userId).collection('transactions');
  }

  Map<String, dynamic> _walletToMap(Wallet wallet) {
    return {
      'id': wallet.id,
      'userId': wallet.userId,
      'baseCurrency': wallet.baseCurrency,
      'balances': wallet.balances,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Wallet _walletFromMap(
    String fallbackWalletId,
    String fallbackUserId,
    Map<String, dynamic> data,
  ) {
    final rawBalances = (data['balances'] as Map<String, dynamic>? ??
        <String, dynamic>{});
    final balances = <String, double>{
      for (final entry in rawBalances.entries)
        entry.key: (entry.value as num).toDouble(),
    };

    return Wallet(
      id: data['id'] as String? ?? fallbackWalletId,
      userId: data['userId'] as String? ?? fallbackUserId,
      baseCurrency: data['baseCurrency'] as String? ?? defaultBaseCurrency,
      balances: balances,
    );
  }

  Map<String, dynamic> _transactionToMap(WalletTransaction transaction) {
    return {
      'id': transaction.id,
      'walletId': transaction.walletId,
      'type': transaction.type.name,
      'status': transaction.status.name,
      'amount': transaction.amount,
      'currency': transaction.currency,
      'description': transaction.description,
      'recipientWalletId': transaction.recipientWalletId,
      'convertedAmount': transaction.convertedAmount,
      'convertedCurrency': transaction.convertedCurrency,
      'exchangeRate': transaction.exchangeRate,
      'createdAt': Timestamp.fromDate(transaction.createdAt),
    };
  }

  WalletTransaction _transactionFromMap(Map<String, dynamic> data) {
    WalletTransactionType parseType(String raw) {
      return WalletTransactionType.values.firstWhere(
        (value) => value.name == raw,
        orElse: () => WalletTransactionType.deposit,
      );
    }

    WalletTransactionStatus parseStatus(String raw) {
      return WalletTransactionStatus.values.firstWhere(
        (value) => value.name == raw,
        orElse: () => WalletTransactionStatus.completed,
      );
    }

    final createdAtRaw = data['createdAt'];
    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else {
      createdAt = DateTime.now();
    }

    return WalletTransaction(
      id: data['id'] as String,
      walletId: data['walletId'] as String,
      type: parseType(data['type'] as String? ?? 'deposit'),
      status: parseStatus(data['status'] as String? ?? 'completed'),
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String,
      createdAt: createdAt,
      description: data['description'] as String?,
      recipientWalletId: data['recipientWalletId'] as String?,
      convertedAmount: (data['convertedAmount'] as num?)?.toDouble(),
      convertedCurrency: data['convertedCurrency'] as String?,
      exchangeRate: (data['exchangeRate'] as num?)?.toDouble(),
    );
  }

  Future<Wallet> _ensureWallet(String userId) async {
    final docRef = _walletDoc(userId);
    final snapshot = await docRef.get();
    if (snapshot.exists && snapshot.data() != null) {
      return _walletFromMap(docRef.id, userId, snapshot.data()!);
    }

    final wallet = _defaultWallet(userId);
    await docRef.set(_walletToMap(wallet), SetOptions(merge: true));
    return wallet;
  }

  Future<void> _appendTransaction(String userId, WalletTransaction tx) async {
    await _transactionsCollection(userId)
        .doc(tx.id)
        .set(_transactionToMap(tx), SetOptions(merge: true));
  }

  @override
  Stream<Wallet> watchWallet(String userId) {
    _assertUserScope(userId);
    final docRef = _walletDoc(_userId);
    return docRef.snapshots().asyncMap((snapshot) async {
      final data = snapshot.data();
      if (snapshot.exists && data != null) {
        return _walletFromMap(docRef.id, _userId, data);
      }

      return _ensureWallet(_userId);
    });
  }

  @override
  Stream<List<WalletTransaction>> watchTransactions(String walletId) {
    final userId = _resolveUserIdFromWalletId(walletId);
    _assertUserScope(userId);
    return _transactionsCollection(_userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _transactionFromMap(doc.data()))
            .toList(growable: false));
  }

  @override
  Future<Wallet?> getWallet(String userId) async {
    _assertUserScope(userId);
    return _ensureWallet(_userId);
  }

  @override
  Future<void> addCurrency({
    required String walletId,
    required String currency,
  }) async {
    final userId = _resolveUserIdFromWalletId(walletId);
    _assertUserScope(userId);
    final wallet = await _ensureWallet(_userId);

    final balances = Map<String, double>.from(wallet.balances);
    balances.putIfAbsent(currency, () => 0);

    await _walletDoc(_userId).set(
      {'balances': balances, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> deposit({
    required String walletId,
    required double amount,
    required String currency,
  }) async {
    final userId = _resolveUserIdFromWalletId(walletId);
    _assertUserScope(userId);
    final wallet = await _ensureWallet(_userId);

    final balances = Map<String, double>.from(wallet.balances);
    balances[currency] = (balances[currency] ?? 0) + amount;

    await _walletDoc(_userId).set(
      {'balances': balances, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );

    await _appendTransaction(
      _userId,
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
  }

  @override
  Future<void> transfer({
    required String sourceWalletId,
    required String destinationWalletId,
    required double amount,
    required String currency,
  }) async {
    final userId = _resolveUserIdFromWalletId(sourceWalletId);
    _assertUserScope(userId);
    final wallet = await _ensureWallet(_userId);

    final balances = Map<String, double>.from(wallet.balances);
    final current = balances[currency] ?? 0;
    if (current < amount) {
      throw Exception('Insufficient funds');
    }

    balances[currency] = current - amount;

    await _walletDoc(_userId).set(
      {'balances': balances, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );

    await _appendTransaction(
      _userId,
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
    _assertUserScope(userId);
    final wallet = await _ensureWallet(_userId);

    final balances = Map<String, double>.from(wallet.balances);
    if ((balances[fromCurrency] ?? 0) < amount) {
      throw Exception('Insufficient funds');
    }

    final convertedAmount = amount * exchangeRate;
    balances[fromCurrency] = (balances[fromCurrency] ?? 0) - amount;
    balances[toCurrency] = (balances[toCurrency] ?? 0) + convertedAmount;

    await _walletDoc(_userId).set(
      {'balances': balances, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );

    await _appendTransaction(
      _userId,
      WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        walletId: walletId,
        type: WalletTransactionType.currencyConversion,
        status: WalletTransactionStatus.completed,
        amount: amount,
        currency: fromCurrency,
        convertedAmount: convertedAmount,
        convertedCurrency: toCurrency,
        exchangeRate: exchangeRate,
        createdAt: DateTime.now(),
        description: 'Currency exchange',
      ),
    );
  }
}
