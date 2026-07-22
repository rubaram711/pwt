import '../../translation_model.dart';

class AdminBannerModel {

  final int? id;

  final String? code;

  final String? placement;

  final TranslationModel? title;

  final TranslationModel? subtitle;

  final String? imageUrl;

  final String? imageUrlAr;

  final TranslationModel? ctaLabel;

  final String? ctaUrl;

  final bool? isActive;

  final String? startsAt;

  final String? endsAt;

  final int? displayOrder;

  final String? deletedAt;

  AdminBannerModel({

    this.id,

    this.code,

    this.placement,

    this.title,

    this.subtitle,

    this.imageUrl,

    this.imageUrlAr,

    this.ctaLabel,

    this.ctaUrl,

    this.isActive,

    this.startsAt,

    this.endsAt,

    this.displayOrder,

    this.deletedAt,
  });

  factory AdminBannerModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return AdminBannerModel();
    }

    return AdminBannerModel(

      id: json['id'],

      code: json['code'],

      placement: json['placement'],

      title:
      TranslationModel.fromJson(
        json['title'],
      ),

      subtitle:
      TranslationModel.fromJson(
        json['subtitle'],
      ),

      imageUrl: json['image_url'],

      imageUrlAr:
      json['image_url_ar'],

      ctaLabel:
      TranslationModel.fromJson(
        json['cta_label'],
      ),

      ctaUrl: json['cta_url'],

      isActive: json['is_active'],

      startsAt: json['starts_at'],

      endsAt: json['ends_at'],

      displayOrder:
      json['display_order'],

      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'code': code,

      'placement': placement,

      'title': title?.toJson(),

      'subtitle':
      subtitle?.toJson(),

      'image_url': imageUrl,

      'image_url_ar':
      imageUrlAr,

      'cta_label':
      ctaLabel?.toJson(),

      'cta_url': ctaUrl,

      'is_active': isActive,

      'starts_at': startsAt,

      'ends_at': endsAt,

      'display_order':
      displayOrder,

      'deleted_at': deletedAt,
    };
  }
}