class AdminBannerDeleteModel {

  final int? id;

  final String? deletedAt;

  AdminBannerDeleteModel({

    this.id,

    this.deletedAt,
  });

  factory AdminBannerDeleteModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminBannerDeleteModel();
    }

    return
      AdminBannerDeleteModel(

        id: json['id'],

        deletedAt: json['deleted_at'],
      );
  }
}