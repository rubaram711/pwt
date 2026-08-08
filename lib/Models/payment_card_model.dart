class PaymentCard {
  final int id;
  final String brand;
  final String lastFour;
  final String expiryMonth;
  final String expiryYear;
  final String cardholderName;
  final String? stripePaymentMethodId;
  final String? stripeCustomerId;
  final bool isDefault;
  final String createdAt;

  PaymentCard({
    required this.id,
    required this.brand,
    required this.lastFour,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    this.stripePaymentMethodId,
    this.stripeCustomerId,
    required this.isDefault,
    required this.createdAt,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'],
      brand: json['brand'] ?? '',
      lastFour: json['last_four'] ?? '',
      expiryMonth: json['expiry_month'] ?? '',
      expiryYear: json['expiry_year'] ?? '',
      cardholderName: json['cardholder_name'] ?? '',
      stripePaymentMethodId: json['stripe_payment_method_id'],
      stripeCustomerId: json['stripe_customer_id'],
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'last_four': lastFour,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'cardholder_name': cardholderName,
      'stripe_payment_method_id': stripePaymentMethodId,
      'stripe_customer_id': stripeCustomerId,
      'is_default': isDefault,
      'created_at': createdAt,
    };
  }
}
