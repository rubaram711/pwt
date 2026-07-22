class CategoryModel {

  final int? id;
  final String? code;
  final String? name;
  final String? description;
  final String? imageUrl;
  final int? displayOrder;
  final bool? isActive;
  final int? productsCount;

  CategoryModel({
    this.id,
    this.code,
    this.name,
    this.description,
    this.imageUrl,
    this.displayOrder,
    this.isActive,
    this.productsCount,
  });

  factory CategoryModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return CategoryModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      displayOrder: json['display_order'],
      isActive: json['is_active'],
      productsCount: json['products_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'display_order': displayOrder,
      'is_active': isActive,
      'products_count': productsCount,
    };
  }
}