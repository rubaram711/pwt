class PaymentStatusModel {
  final int paymentId;
  final String publicId;
  final int orderId;
  final String status;
  final String paymentMethod;
  final String amount;
  final String currency;
  final String? capturedAt;
  final String? failedAt;
  final String? failureReason;

  PaymentStatusModel({
    required this.paymentId,
    required this.publicId,
    required this.orderId,
    required this.status,
    required this.paymentMethod,
    required this.amount,
    required this.currency,
    this.capturedAt,
    this.failedAt,
    this.failureReason,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      paymentId: json['payment_id'],
      publicId: json['public_id'],
      orderId: json['order_id'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      amount: json['amount'].toString(),
      currency: json['currency'],
      capturedAt: json['captured_at'],
      failedAt: json['failed_at'],
      failureReason: json['failure_reason'],
    );
  }
}