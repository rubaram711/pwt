import '../../translation_model.dart';

class AdminCategoryModel {

  final int? id;

  final String? code;

  final TranslationModel? name;

  final TranslationModel? description;

  final bool? isActive;

  final int? displayOrder;

  final int? productsCount;

  final String? deletedAt;

  AdminCategoryModel({
    this.id,
    this.code,
    this.name,
    this.description,
    this.isActive,
    this.displayOrder,
    this.productsCount,
    this.deletedAt,
  });

  factory AdminCategoryModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminCategoryModel(

      id: json['id'],

      code: json['code'],

      name:
      json['name'] != null

          ? TranslationModel.fromJson(
        json['name'],
      )

          : null,

      description:
      json['description'] != null

          ? TranslationModel.fromJson(
        json['description'],
      )

          : null,

      isActive:
      json['is_active'],

      displayOrder:
      json['display_order'],

      productsCount:
      json['products_count'],

      deletedAt:
      json['deleted_at'],
    );
  }
}