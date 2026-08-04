import 'package:equatable/equatable.dart';

enum WalletTransactionType {
  deposit,
  transferIn,
  transferOut,
  currencyConversion,
}

enum WalletTransactionStatus {
  pending,
  completed,
  failed,
}

class WalletTransaction extends Equatable {
  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    required this.createdAt,
    this.description,
    this.recipientWalletId,
    this.convertedAmount,
    this.convertedCurrency,
    this.exchangeRate,
  });

  final String id;
  final String walletId;
  final WalletTransactionType type;
  final WalletTransactionStatus status;
  final double amount;
  final String currency;
  final String? description;
  final String? recipientWalletId;
  final double? convertedAmount;
  final String? convertedCurrency;
  final double? exchangeRate;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        walletId,
        type,
        status,
        amount,
        currency,
        description,
        recipientWalletId,
        convertedAmount,
        convertedCurrency,
        exchangeRate,
        createdAt,
      ];
}
