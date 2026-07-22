import 'promotion_discount_model.dart';

class ValidatePromotionModel {

  final bool valid;

  final String code;

  final PromotionDiscountModel?
  discount;

  final String? appliedAmount;

  final String? appliesTo;

  final String reasonCode;

  ValidatePromotionModel({

    required this.valid,

    required this.code,

    this.discount,

    this.appliedAmount,

    this.appliesTo,

    required this.reasonCode,
  });

  factory ValidatePromotionModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return ValidatePromotionModel(

      valid: json['valid'] ?? false,

      code: json['code'] ?? '',

      discount:
      json['discount'] != null

          ? PromotionDiscountModel
          .fromJson(
        json['discount'],
      )

          : null,

      appliedAmount:
      json['applied_amount']?.toString(),

      appliesTo:
      json['applies_to'],

      reasonCode:
      json['reason_code'] ?? '',
    );
  }
}