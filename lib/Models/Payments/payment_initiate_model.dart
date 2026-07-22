class PaymentInitiateModel {
  final int paymentId;
  final String publicId;
  final int orderId;
  final String status;
  final String? paymentUrl;
  final String expiresAt;
  final String amount;
  final String currency;
  final String gateway;

  PaymentInitiateModel({
    required this.paymentId,
    required this.publicId,
    required this.orderId,
    required this.status,
    required this.paymentUrl,
    required this.expiresAt,
    required this.amount,
    required this.currency,
    required this.gateway,
  });

  factory PaymentInitiateModel.fromJson(Map<String, dynamic> json) {
    return PaymentInitiateModel(
      paymentId: json['payment_id'],
      publicId: json['public_id'],
      orderId: json['order_id'],
      status: json['status'],
      paymentUrl: json['payment_url'],
      expiresAt: json['expires_at'],
      amount: json['amount'].toString(),
      currency: json['currency'],
      gateway: json['gateway'],
    );
  }
}