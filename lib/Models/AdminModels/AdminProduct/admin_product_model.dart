import '../../../Models/translation_model.dart';

import 'admin_product_category_model.dart';
import 'admin_product_image_model.dart';
import 'admin_product_price_model.dart';
import 'admin_product_spec_model.dart';

class AdminProductModel {

  final int? id;

  final String? code;

  final TranslationModel? name;

  final TranslationModel? shortDescription;

  final TranslationModel? description;

  final Map<String, dynamic>? benefits;

  final bool? isActive;

  final bool? isFeatured;

  final bool? isQuoteOnly;

  final String? stockStatus;

  final int? displayOrder;

  final int? pricesCount;

  final String? deletedAt;

  final AdminProductCategoryModel?
  category;

  final List<AdminProductPriceModel>
  prices;

  final List<AdminProductSpecModel>
  specs;

  final List<AdminProductImageModel>
  images;

  AdminProductModel({
    this.id,
    this.code,
    this.name,
    this.shortDescription,
    this.description,
    this.benefits,
    this.isActive,
    this.isFeatured,
    this.isQuoteOnly,
    this.stockStatus,
    this.displayOrder,
    this.pricesCount,
    this.deletedAt,
    this.category,
    required this.prices,
    required this.specs,
    required this.images,
  });

  factory AdminProductModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminProductModel(

      id: json['id'],

      code: json['code'],

      name:
      json['name'] != null

          ? TranslationModel.fromJson(
        json['name'],
      )

          : null,

      shortDescription:
      json['short_description']
          !=
          null

          ? TranslationModel.fromJson(
        json['short_description'],
      )

          : null,

      description:
      json['description'] != null

          ? TranslationModel.fromJson(
        json['description'],
      )

          : null,

      benefits:
      json['benefits'],

      isActive:
      json['is_active'],

      isFeatured:
      json['is_featured'],

      isQuoteOnly:
      json['is_quote_only'],

      stockStatus:
      json['stock_status'],

      displayOrder:
      json['display_order'],

      pricesCount:
      json['prices_count'],

      deletedAt:
      json['deleted_at'],

      category:
      json['category'] != null

          ? AdminProductCategoryModel
          .fromJson(
        json['category'],
      )

          : null,

      prices:
      json['prices'] != null

          ? List<
          AdminProductPriceModel>.from(

        json['prices'].map(

              (x) =>
              AdminProductPriceModel
                  .fromJson(x),
        ),
      )

          : [],

      specs:
      json['specs'] != null

          ? List<
          AdminProductSpecModel>.from(

        json['specs'].map(

              (x) =>
              AdminProductSpecModel
                  .fromJson(x),
        ),
      )

          : [],

      images:
      json['images'] != null

          ? List<
          AdminProductImageModel>.from(

        json['images'].map(

              (x) =>
              AdminProductImageModel
                  .fromJson(x),
        ),
      )

          : [],
    );
  }
}