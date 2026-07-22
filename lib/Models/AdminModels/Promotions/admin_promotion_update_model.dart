class AdminPromotionUpdateModel {

  final int? id;

  final String? code;

  final bool? isActive;

  AdminPromotionUpdateModel({

    this.id,

    this.code,

    this.isActive,
  });

  factory AdminPromotionUpdateModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminPromotionUpdateModel();
    }

    return
      AdminPromotionUpdateModel(

        id: json['id'],

        code: json['code'],

        isActive: json['is_active'],
      );
  }
}