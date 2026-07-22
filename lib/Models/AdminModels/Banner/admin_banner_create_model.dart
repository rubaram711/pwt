class AdminBannerCreateModel {

  final int? id;

  final String? code;

  final String? placement;

  final bool? isActive;

  AdminBannerCreateModel({

    this.id,

    this.code,

    this.placement,

    this.isActive,
  });

  factory AdminBannerCreateModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminBannerCreateModel();
    }

    return
      AdminBannerCreateModel(

        id: json['id'],

        code: json['code'],

        placement: json['placement'],

        isActive: json['is_active'],
      );
  }
}