/// Returned by POST /payments/initiate
class PaymentModel {
  final int paymentId;
  final String publicId;
  final int orderId;
  final String status;
  final String? paymentMethod;
  final String? gateway;
  final String amount;
  final String currency;
  final String? paymentUrl;
  final String? expiresAt;
  final String? capturedAt;
  final String? failedAt;
  final String? cancelledAt;
  final String? failureReason;
  final String? createdAt;
  final String? sessionId;
  final String? paymentReference;
  final String? paymentToken;
  final String? clientSecret;

  PaymentModel({
    required this.paymentId,
    required this.publicId,
    required this.orderId,
    required this.status,
    this.paymentMethod,
    this.gateway,
    required this.amount,
    required this.currency,
    this.paymentUrl,
    this.expiresAt,
    this.capturedAt,
    this.failedAt,
    this.cancelledAt,
    this.failureReason,
    this.createdAt,
    this.sessionId,
    this.paymentReference,
    this.paymentToken,
    this.clientSecret,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        paymentId: json['payment_id'],
        publicId: json['public_id'] ?? '',
        orderId: json['order_id'],
        status: json['status'] ?? '',
        paymentMethod: json['payment_method'],
        gateway: json['gateway'],
        amount: json['amount']?.toString() ?? '0.00',
        currency: json['currency'] ?? 'AED',
        paymentUrl: json['payment_url'],
        expiresAt: json['expires_at'],
        capturedAt: json['captured_at'],
        failedAt: json['failed_at'],
        cancelledAt: json['cancelled_at'],
        failureReason: json['failure_reason'],
        createdAt: json['created_at'],
        sessionId: json['session_id'],
        paymentReference: json['payment_reference'],
        paymentToken: json['payment_token'],
        clientSecret: json['client_secret'],
      );
}

/// Returned by GET /payments/:id/status
class PaymentStatusModel {
  final int paymentId;
  final String publicId;
  final int orderId;
  final String status; // initiated | captured | failed | cancelled
  final String? paymentMethod;
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
    this.paymentMethod,
    required this.amount,
    required this.currency,
    this.capturedAt,
    this.failedAt,
    this.failureReason,
  });

  bool get isCaptured => status == 'captured';
  bool get isFailed => status == 'failed' || status == 'cancelled';
  bool get isPending => !isCaptured && !isFailed;

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) => PaymentStatusModel(
        paymentId: json['payment_id'],
        publicId: json['public_id'] ?? '',
        orderId: json['order_id'],
        status: json['status'] ?? '',
        paymentMethod: json['payment_method'],
        amount: json['amount']?.toString() ?? '0.00',
        currency: json['currency'] ?? 'AED',
        capturedAt: json['captured_at'],
        failedAt: json['failed_at'],
        failureReason: json['failure_reason'],
      );
}
