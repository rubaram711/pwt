class PromotionDiscountModel {

  final String type;

  final String value;

  final String currency;

  PromotionDiscountModel({

    required this.type,

    required this.value,

    required this.currency,
  });

  factory PromotionDiscountModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return PromotionDiscountModel(

      type: json['type'] ?? '',

      value: json['value']?.toString() ?? '',

      currency:
      json['currency']?.toString() ?? '',
    );
  }
}