import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../data/repositories/in_memory_wallet_repository.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final defaults = ref.watch(profileDefaultsProvider);
  return InMemoryWalletRepository(
    defaultBaseCurrency: defaults.preferredCurrencyCode,
  );
});

final walletUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserIdProvider);
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

  return ref.watch(walletRepositoryProvider).watchTransactions('wallet-$userId');
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
