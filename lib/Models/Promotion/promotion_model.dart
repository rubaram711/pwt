class PromotionModel {

  final int id;

  final String code;

  final String name;

  final String? description;

  final String type;

  final String value;

  final String? maxDiscountAmount;

  final String? minOrderAmount;

  final String startsAt;

  final String endsAt;

  final String appliesTo;

  final int userRedemptionsRemaining;

  PromotionModel({

    required this.id,

    required this.code,

    required this.name,

    this.description,

    required this.type,

    required this.value,

    this.maxDiscountAmount,

    this.minOrderAmount,

    required this.startsAt,

    required this.endsAt,

    required this.appliesTo,

    required this.userRedemptionsRemaining,
  });

  factory PromotionModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return PromotionModel(

      id: json['id'] ?? 0,

      code: json['code'] ?? '',

      name: json['name'] ?? '',

      description: json['description'],

      type: json['type'] ?? '',

      value: json['value'] ?? '',

      maxDiscountAmount:
      json['max_discount_amount'],

      minOrderAmount:
      json['min_order_amount'],

      startsAt:
      json['starts_at'] ?? '',

      endsAt:
      json['ends_at'] ?? '',

      appliesTo:
      json['applies_to'] ?? '',

      userRedemptionsRemaining:

      json['user_redemptions_remaining']
          ?? 0,
    );
  }
}