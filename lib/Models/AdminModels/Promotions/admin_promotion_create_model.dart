class AdminPromotionCreateModel {

  final int? id;

  final String? code;

  final String? type;

  final String? value;

  final bool? isActive;

  AdminPromotionCreateModel({

    this.id,

    this.code,

    this.type,

    this.value,

    this.isActive,
  });

  factory AdminPromotionCreateModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminPromotionCreateModel();
    }

    return
      AdminPromotionCreateModel(

        id: json['id'],

        code: json['code'],

        type: json['type'],

        value:
        json['value']?.toString(),

        isActive: json['is_active'],
      );
  }
}