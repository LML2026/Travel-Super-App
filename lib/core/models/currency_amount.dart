class CurrencyAmount {
  final double amount;
  final String currency;

  const CurrencyAmount({
    required this.amount,
    required this.currency,
  });

  CurrencyAmount copyWith({
    double? amount,
    String? currency,
  }) {
    return CurrencyAmount(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency,
    };
  }

  factory CurrencyAmount.fromMap(Map<String, dynamic> map) {
    return CurrencyAmount(
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
    );
  }
}
