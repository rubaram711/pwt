class AdminPromotionDeleteModel {

  final int? id;

  final String? deletedAt;

  AdminPromotionDeleteModel({

    this.id,

    this.deletedAt,
  });

  factory AdminPromotionDeleteModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminPromotionDeleteModel();
    }

    return
      AdminPromotionDeleteModel(

        id: json['id'],

        deletedAt: json['deleted_at'],
      );
  }
}