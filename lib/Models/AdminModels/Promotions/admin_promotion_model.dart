import '../../translation_model.dart';

class AdminPromotionModel {

  final int? id;

  final String? code;

  final TranslationModel? name;

  final TranslationModel? description;

  final String? type;

  final String? value;

  final String? maxDiscountAmount;

  final String? minOrderAmount;

  final String? currency;

  final String? appliesTo;

  final int? totalLimit;

  final int? perUserLimit;

  final int? redemptionsCount;

  final bool? isActive;

  final String? startsAt;

  final String? endsAt;

  final String? deletedAt;

  AdminPromotionModel({

    this.id,

    this.code,

    this.name,

    this.description,

    this.type,

    this.value,

    this.maxDiscountAmount,

    this.minOrderAmount,

    this.currency,

    this.appliesTo,

    this.totalLimit,

    this.perUserLimit,

    this.redemptionsCount,

    this.isActive,

    this.startsAt,

    this.endsAt,

    this.deletedAt,
  });

  factory AdminPromotionModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return AdminPromotionModel();
    }

    return AdminPromotionModel(

      id: json['id'],

      code: json['code'],

      name:
      TranslationModel.fromJson(
        json['name'],
      ),

      description:
      TranslationModel.fromJson(
        json['description'],
      ),

      type: json['type'],

      value:
      json['value']?.toString(),

      maxDiscountAmount:
      json['max_discount_amount']
          ?.toString(),

      minOrderAmount:
      json['min_order_amount']
          ?.toString(),

      currency: json['currency'],

      appliesTo:
      json['applies_to'],

      totalLimit:
      json['total_limit'],

      perUserLimit:
      json['per_user_limit'],

      redemptionsCount:
      json['redemptions_count'],

      isActive: json['is_active'],

      startsAt: json['starts_at'],

      endsAt: json['ends_at'],

      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'code': code,

      'name': name?.toJson(),

      'description':
      description?.toJson(),

      'type': type,

      'value': value,

      'max_discount_amount':
      maxDiscountAmount,

      'min_order_amount':
      minOrderAmount,

      'currency': currency,

      'applies_to': appliesTo,

      'total_limit': totalLimit,

      'per_user_limit':
      perUserLimit,

      'redemptions_count':
      redemptionsCount,

      'is_active': isActive,

      'starts_at': startsAt,

      'ends_at': endsAt,

      'deleted_at': deletedAt,
    };
  }
}