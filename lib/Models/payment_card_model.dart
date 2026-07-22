class PaymentCard {
  final int id;
  final String brand;
  final String lastFour;
  final String? cardNumberHash;
  final String expiryMonth;
  final String expiryYear;
  final String cardholderName;
  final String? cvc;
  final bool isDefault;
  final String createdAt;

  PaymentCard({
    required this.id,
    required this.brand,
    required this.lastFour,
    this.cardNumberHash,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    this.cvc,
    required this.isDefault,
    required this.createdAt,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'],
      brand: json['brand'] ?? '',
      lastFour: json['last_four'] ?? '',
      cardNumberHash: json['card_number_hash'],
      expiryMonth: json['expiry_month'] ?? '',
      expiryYear: json['expiry_year'] ?? '',
      cardholderName: json['cardholder_name'] ?? '',
      cvc: json['cvc'],
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
      'is_default': isDefault,
      'created_at': createdAt,
    };
  }
}
