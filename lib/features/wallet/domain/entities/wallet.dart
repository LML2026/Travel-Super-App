import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  const Wallet({
    required this.id,
    required this.userId,
    required this.baseCurrency,
    required this.balances,
  });

  final String id;
  final String userId;
  final String baseCurrency;
  final Map<String, double> balances;

  Wallet copyWith({
    String? id,
    String? userId,
    String? baseCurrency,
    Map<String, double>? balances,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      balances: balances ?? this.balances,
    );
  }

  @override
  List<Object?> get props => [id, userId, baseCurrency, balances];
}
