enum PaymentStatus {
  pending,
  succeeded,
  failed,
  cancelled,
}

class PaymentResult {
  final String requestId;
  final PaymentStatus status;
  final String? transactionId;
  final String? message;

  const PaymentResult({
    required this.requestId,
    required this.status,
    this.transactionId,
    this.message,
  });

  bool get isSuccess => status == PaymentStatus.succeeded;
}
