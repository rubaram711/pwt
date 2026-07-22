// import '../category_model.dart';
// import 'product_image_model.dart';
// import 'product_price_model.dart';
// import 'product_spec_model.dart';
//
// class ProductDetailsModel {
//
//   final int? id;
//   final String? code;
//   final String? name;
//   final String? description;
//
//   final List<String> benefits;
//
//   final CategoryModel? category;
//
//   final List<ProductImageModel> images;
//   final List<ProductSpecModel> specs;
//   final List<ProductPriceModel> prices;
//
//   final String? stockStatus;
//
//   final bool? isFeatured;
//   final bool? isQuoteOnly;
//
//   final int? promotionsCount;
//
//   ProductDetailsModel({
//     this.id,
//     this.code,
//     this.name,
//     this.description,
//     required this.benefits,
//     this.category,
//     required this.images,
//     required this.specs,
//     required this.prices,
//     this.stockStatus,
//     this.isFeatured,
//     this.isQuoteOnly,
//     this.promotionsCount,
//   });
//
//   factory ProductDetailsModel.fromJson(
//       Map<String, dynamic> json,
//       ) {
//
//     return ProductDetailsModel(
//
//       id: json['id'],
//       code: json['code'],
//       name: json['name'],
//       description: json['description'],
//
//       benefits:
//       json['benefits'] != null
//           ? List<String>.from(
//         json['benefits'],
//       )
//           : [],
//
//       category: json['category'] != null
//           ? CategoryModel.fromJson(
//         json['category'],
//       )
//           : null,
//
//       images: json['images'] != null
//           ? List<ProductImageModel>.from(
//         json['images'].map(
//               (x) => ProductImageModel.fromJson(x),
//         ),
//       )
//           : [],
//
//       specs: json['specs'] != null
//           ? List<ProductSpecModel>.from(
//         json['specs'].map(
//               (x) => ProductSpecModel.fromJson(x),
//         ),
//       )
//           : [],
//
//       prices: json['prices'] != null
//           ? List<ProductPriceModel>.from(
//         json['prices'].map(
//               (x) => ProductPriceModel.fromJson(x),
//         ),
//       )
//           : [],
//
//       stockStatus:
//       json['stock_status'],
//
//       isFeatured:
//       json['is_featured'],
//
//       isQuoteOnly:
//       json['is_quote_only'],
//
//       promotionsCount:
//       json['promotions_count'],
//     );
//   }
// }