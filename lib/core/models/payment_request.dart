import 'currency_amount.dart';

class PaymentRequest {
  final String id;
  final CurrencyAmount amount;
  final String description;
  final String merchantName;
  final String? bookingReference;

  const PaymentRequest({
    required this.id,
    required this.amount,
    required this.description,
    required this.merchantName,
    this.bookingReference,
  });
}
