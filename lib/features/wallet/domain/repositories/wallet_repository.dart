import '../entities/wallet.dart';
import '../entities/wallet_transaction.dart';

abstract class WalletRepository {
  Stream<Wallet> watchWallet(String userId);

  Stream<List<WalletTransaction>> watchTransactions(String walletId);

  Future<Wallet?> getWallet(String userId);

  Future<void> deposit({
    required String walletId,
    required double amount,
    required String currency,
  });

  Future<void> transfer({
    required String sourceWalletId,
    required String destinationWalletId,
    required double amount,
    required String currency,
  });

  Future<void> convertCurrency({
    required String walletId,
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required double exchangeRate,
  });
}
