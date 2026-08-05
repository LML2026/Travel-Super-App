import 'package:equatable/equatable.dart';

class CoinWallet extends Equatable {
  const CoinWallet({
    required this.walletId,
    required this.balance,
    required this.symbol,
    required this.valueInGbp,
  });

  final String walletId;
  final int balance;
  final String symbol;
  final String valueInGbp;

  @override
  List<Object?> get props => [walletId, balance, symbol, valueInGbp];
}
