import 'package:pwt_website/Models/Products/product_image_model.dart';
import 'package:pwt_website/Models/Products/product_price_model.dart';
import 'package:pwt_website/Models/Products/product_spec_model.dart';

import '../category_model.dart';
class ProductModel {

  final int? id;
  final String? uuid;
  final String? code;
  final String? sku;

  final String? name;
  final String? description;
  final String? shortDescription;

  final String? localizedName;
  final String? localizedDescription;

  final CategoryModel? category;

  final List<ProductImageModel> images;

  final List<ProductSpecModel> specs;

  final List<ProductPriceModel> prices;
  final ProductPriceModel? startingPrice;

  final List<String> benefits;

  final bool? isFeatured;
  final bool? isQuoteOnly;
  final bool? isActive;

  final String? stockStatus;

  final String? primaryImageUrl;

  final int? promotionsCount;
  final int? discount;
  final String? originalPrice;
  final String? discountPercentage;
  final String? finalPrice;
  final String? rentStars;
  final String? tagLabel;
  final String? createdAt;

  ProductModel({
    this.id,
    this.uuid,
    this.code,
    this.sku,
    this.name,
    this.description,
    this.shortDescription,
    this.localizedName,
    this.localizedDescription,
    this.category,
    this.images = const [],
    this.specs = const [],
    this.prices = const [],
    this.startingPrice,
    this.benefits = const [],
    this.isFeatured,
    this.isQuoteOnly,
    this.isActive,
    this.stockStatus,
    this.primaryImageUrl,
    this.promotionsCount,
    this.discount,
    this.originalPrice,
    this.discountPercentage,
    this.finalPrice,
    this.rentStars,
    this.tagLabel,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      uuid: json['uuid'],
      code: json['code'],
      sku: json['sku'],

      name: json['name'],
      description: json['description'],
      shortDescription: json['short_description'],

      localizedName: json['localized_name'],
      localizedDescription: json['localized_description'],

      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,

      images: json['images'] != null
          ? List<ProductImageModel>.from(
        json['images'].map(
              (x) => ProductImageModel.fromJson(x),
        ),
      )
          : [],

      specs: json['specs'] != null
          ? List<ProductSpecModel>.from(
        json['specs'].map(
              (x) => ProductSpecModel.fromJson(x),
        ),
      )
          : [],

      prices: json['prices'] != null
          ? List<ProductPriceModel>.from(
        json['prices'].map(
              (x) => ProductPriceModel.fromJson(x),
        ),
      )
          : [],

            startingPrice:
      json['starting_price'] != null
          ? ProductPriceModel.fromJson(
        json['starting_price'],
      )
          : null,


      benefits: json['benefits'] != null
          ? List<String>.from(json['benefits'])
          : [],

      isFeatured: json['is_featured'],
      isQuoteOnly: json['is_quote_only'],
      isActive: json['is_active'],

      stockStatus: json['stock_status'],

      primaryImageUrl: json['primary_image_url'],

      promotionsCount: json['promotions_count'],
      discount: json['discount'],
      originalPrice: json['original_price']?.toString(),
      discountPercentage: json['discount_percentage']?.toString(),
      finalPrice: json['final_price']?.toString(),
      rentStars: json['rent_stars']?.toString(),
      tagLabel: json['tag_label'],
      createdAt: json['created_at'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'code': code,
      'sku': sku,

      'name': name,
      'description': description,
      'short_description': shortDescription,

      'localized_name': localizedName,
      'localized_description': localizedDescription,

      'category': category?.toJson(),

      'images': images
          .map((e) => e.toJson())
          .toList(),

      'specs': specs
          .map((e) => e.toJson())
          .toList(),

      'prices': prices
          .map((e) => e.toJson())
          .toList(),

      'starting_price':  startingPrice?.toJson(),

      'benefits': benefits,

      'is_featured': isFeatured,
      'is_quote_only': isQuoteOnly,
      'is_active': isActive,

      'stock_status': stockStatus,

      'primary_image_url': primaryImageUrl,

      'promotions_count': promotionsCount,
      'discount': discount,
      'original_price': originalPrice,
      'discount_percentage': discountPercentage,
      'final_price': finalPrice,
      'rent_stars': rentStars,
      'tag_label': tagLabel,
      'created_at': createdAt,
    };
  }
}
// class ProductModel {
//   final int id;
//   final String uuid;
//   final String? categoryId;
//   final String sku;
//
//   final Map<String, dynamic>? name;
//   final Map<String, dynamic>? description;
//
//   final Map<String, dynamic>? specifications;
//   final Map<String, dynamic>? benefits;
//
//   final String purchasePrice;
//   final String rentalPricePerMonth;
//   final String rentalMinTermMonths;
//
//   final bool isPublicPrice;
//   final bool isActive;
//   final bool isFeatured;
//
//   final String stockStatus;
//
//   final String localizedName;
//   final String localizedDescription;
//
//   final List<dynamic> images;
//
//   final CategoryModel? category;
//
//   ProductModel({
//     required this.id,
//     required this.uuid,
//     required this.categoryId,
//     required this.sku,
//     required this.name,
//     required this.description,
//     required this.specifications,
//     required this.benefits,
//     required this.purchasePrice,
//     required this.rentalPricePerMonth,
//     required this.rentalMinTermMonths,
//     required this.isPublicPrice,
//     required this.isActive,
//     required this.isFeatured,
//     required this.stockStatus,
//     required this.localizedName,
//     required this.localizedDescription,
//     required this.images,
//     required this.category,
//   });
//
//   factory ProductModel.fromJson(Map<String, dynamic> json) {
//     return ProductModel(
//       id: json['id'] ?? 0,
//       uuid: json['uuid'] ?? '',
//       categoryId: json['category_id'],
//       sku: json['sku'] ?? '',
//
//       name: json['name'],
//       description: json['description'],
//
//       specifications: json['specifications'],
//       benefits: json['benefits'],
//
//       purchasePrice: json['purchase_price'] ?? '',
//       rentalPricePerMonth:
//       json['rental_price_per_month'] ?? '',
//
//       rentalMinTermMonths:
//       json['rental_min_term_months'] ?? '',
//
//       isPublicPrice:
//       json['is_public_price'] ?? false,
//
//       isActive: json['is_active'] ?? false,
//
//       isFeatured:
//       json['is_featured'] ?? false,
//
//       stockStatus: json['stock_status'] ?? '',
//
//       localizedName:
//       json['localized_name'] ?? '',
//
//       localizedDescription:
//       json['localized_description'] ?? '',
//
//       images: json['images'] != null
//           ? List<dynamic>.from(json['images'])
//           : [],
//
//       category: json['category'] != null
//           ? CategoryModel.fromJson(json['category'])
//           : null,
//     );
//   }
//
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'uuid': uuid,
//       'category_id': categoryId,
//       'sku': sku,
//       'name': name,
//       'description': description,
//       'specifications': specifications,
//       'benefits': benefits,
//       'purchase_price': purchasePrice,
//       'rental_price_per_month': rentalPricePerMonth,
//       'rental_min_term_months': rentalMinTermMonths,
//       'is_public_price': isPublicPrice,
//       'is_active': isActive,
//       'is_featured': isFeatured,
//       'stock_status': stockStatus,
//       'localized_name': localizedName,
//       'localized_description': localizedDescription,
//       'images': images,
//       'category': category,
//     };
//   }
// }