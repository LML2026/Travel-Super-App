import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/firestore_wallet_repository.dart';
import '../../data/repositories/in_memory_wallet_repository.dart';
import '../../data/services/wallet_fx_service.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';

class FxPair {
  const FxPair({required this.base, required this.target});

  final String base;
  final String target;
}

const List<String> kSupportedWalletCurrencies = <String>[
  'GBP',
  'EUR',
  'USD',
  'GEL',
  'RUB',
  'TRY',
  'AED',
];

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final userId = ref.watch(walletUserIdProvider);
  if (userId == null || userId.isEmpty) {
    return InMemoryWalletRepository(
      defaultBaseCurrency: 'GBP',
    );
  }

  return FirestoreWalletRepository(
    userId: userId,
    defaultBaseCurrency: 'GBP',
  );
});

final walletFxServiceProvider = Provider<WalletFxService>((ref) {
  return WalletFxService();
});

final fxRateProvider = FutureProvider.family<double, FxPair>((ref, pair) async {
  return ref.watch(walletFxServiceProvider).getRate(
        base: pair.base,
        target: pair.target,
      );
});

final walletUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});

final walletProvider = StreamProvider<Wallet>((ref) {
  final userId = ref.watch(walletUserIdProvider);
  if (userId == null || userId.isEmpty) {
    return Stream.error(StateError('Authentication required to load wallet.'));
  }

  return ref.watch(walletRepositoryProvider).watchWallet(userId);
});

final walletTransactionsProvider =
    StreamProvider<List<WalletTransaction>>((ref) {
  final userId = ref.watch(walletUserIdProvider);
  if (userId == null || userId.isEmpty) {
    return Stream.error(
      StateError('Authentication required to load wallet transactions.'),
    );
  }

  return ref
      .watch(walletRepositoryProvider)
      .watchTransactions('wallet-$userId');
});

final walletCurrenciesProvider = Provider<List<String>>((ref) {
  final walletAsync = ref.watch(walletProvider);
  final wallet = walletAsync.valueOrNull;

  final currencies = wallet?.balances.keys.toList() ?? const <String>[];
  return currencies..sort();
});

class WalletActions {
  WalletActions.authenticated(this._repository, this._walletId)
      : isAuthenticated = true;

  const WalletActions.unauthenticated()
      : _repository = null,
        _walletId = null,
        isAuthenticated = false;

  final WalletRepository? _repository;
  final String? _walletId;
  final bool isAuthenticated;

  Never _throwUnauthenticated() {
    throw StateError('Authentication required for wallet actions.');
  }

  Future<void> deposit(double amount, String currency) {
    final repository = _repository;
    final walletId = _walletId;
    if (repository == null || walletId == null) {
      _throwUnauthenticated();
    }

    return repository.deposit(
      walletId: walletId,
      amount: amount,
      currency: currency,
    );
  }

  Future<void> addCurrency(String currency) {
    final repository = _repository;
    final walletId = _walletId;
    if (repository == null || walletId == null) {
      _throwUnauthenticated();
    }

    return repository.addCurrency(
      walletId: walletId,
      currency: currency,
    );
  }

  Future<void> transfer(
    double amount,
    String currency,
    String destinationWalletId,
  ) {
    final repository = _repository;
    final walletId = _walletId;
    if (repository == null || walletId == null) {
      _throwUnauthenticated();
    }

    return repository.transfer(
      sourceWalletId: walletId,
      destinationWalletId: destinationWalletId,
      amount: amount,
      currency: currency,
    );
  }

  Future<void> convert({
    required double amount,
    required String from,
    required String to,
    required double rate,
  }) {
    final repository = _repository;
    final walletId = _walletId;
    if (repository == null || walletId == null) {
      _throwUnauthenticated();
    }

    return repository.convertCurrency(
      walletId: walletId,
      amount: amount,
      fromCurrency: from,
      toCurrency: to,
      exchangeRate: rate,
    );
  }
}

final walletActionsProvider = Provider<WalletActions>((ref) {
  final userId = ref.watch(walletUserIdProvider);
  if (userId == null || userId.isEmpty) {
    return const WalletActions.unauthenticated();
  }

  return WalletActions.authenticated(
    ref.watch(walletRepositoryProvider),
    'wallet-$userId',
  );
});
