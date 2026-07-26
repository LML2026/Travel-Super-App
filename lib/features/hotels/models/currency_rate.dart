class CurrencyRate {
  const CurrencyRate({
    required this.base,
    required this.target,
    required this.rate,
  });

  final String base;
  final String target;
  final double rate;

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      base: json['base']?.toString() ?? 'GBP',
      target: json['target']?.toString() ?? 'EUR',
      rate: double.tryParse(json['rate']?.toString() ?? '') ?? 0,
    );
  }
}
