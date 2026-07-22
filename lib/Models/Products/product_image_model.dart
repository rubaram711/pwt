class ProductImageModel {

  final int? id;
  final String? url;
  final String? altText;
  final bool? isPrimary;
  final int? displayOrder;

  ProductImageModel({
    this.id,
    this.url,
    this.altText,
    this.isPrimary,
    this.displayOrder,
  });

  factory ProductImageModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return ProductImageModel(
      id: json['id'],
      url: json['url'],
      altText: json['alt_text'],
      isPrimary: json['is_primary'],
      displayOrder: json['display_order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'alt_text': altText,
      'is_primary': isPrimary,
      'display_order': displayOrder,
    };
  }
}