class AdminBannerUpdateModel {

  final int? id;

  final String? code;

  final bool? isActive;

  AdminBannerUpdateModel({

    this.id,

    this.code,

    this.isActive,
  });

  factory AdminBannerUpdateModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminBannerUpdateModel();
    }

    return
      AdminBannerUpdateModel(

        id: json['id'],

        code: json['code'],

        isActive: json['is_active'],
      );
  }
}