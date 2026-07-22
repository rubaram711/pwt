class BannerModel {

  final int id;

  final String code;

  final String placement;

  final String title;

  final String? subtitle;

  final String imageUrl;

  final String? ctaLabel;

  final String? ctaUrl;

  final int displayOrder;

  BannerModel({

    required this.id,

    required this.code,

    required this.placement,

    required this.title,

    this.subtitle,

    required this.imageUrl,

    this.ctaLabel,

    this.ctaUrl,

    required this.displayOrder,
  });

  factory BannerModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return BannerModel(

      id: json['id'] ?? 0,

      code: json['code'] ?? '',

      placement:
      json['placement'] ?? '',

      title: json['title'] ?? '',

      subtitle: json['subtitle'],

      imageUrl:
      json['image_url'] ?? '',

      ctaLabel:
      json['cta_label'],

      ctaUrl:
      json['cta_url'],

      displayOrder:
      json['display_order'] ?? 0,
    );
  }
}