// import '../category_model.dart';
// import 'product_price_model.dart';
//
// class ProductListModel {
//
//   final int? id;
//   final String? code;
//   final String? name;
//   final String? shortDescription;
//
//   final String? primaryImageUrl;
//
//   final ProductPriceModel? startingPrice;
//
//   final CategoryModel? category;
//
//   final bool? isQuoteOnly;
//   final String? stockStatus;
//   final bool? isFeatured;
//
//   final String? createdAt;
//
//   ProductListModel({
//     this.id,
//     this.code,
//     this.name,
//     this.shortDescription,
//     this.primaryImageUrl,
//     this.startingPrice,
//     this.category,
//     this.isQuoteOnly,
//     this.stockStatus,
//     this.isFeatured,
//     this.createdAt,
//   });
//
//   factory ProductListModel.fromJson(
//       Map<String, dynamic> json,
//       ) {
//
//     return ProductListModel(
//       id: json['id'],
//       code: json['code'],
//       name: json['name'],
//
//       shortDescription:
//       json['short_description'],
//
//       primaryImageUrl:
//       json['primary_image_url'],
//
//       startingPrice:
//       json['starting_price'] != null
//           ? ProductPriceModel.fromJson(
//         json['starting_price'],
//       )
//           : null,
//
//       category: json['category'] != null
//           ? CategoryModel.fromJson(
//         json['category'],
//       )
//           : null,
//
//       isQuoteOnly:
//       json['is_quote_only'],
//
//       stockStatus:
//       json['stock_status'],
//
//       isFeatured:
//       json['is_featured'],
//
//       createdAt:
//       json['created_at'],
//     );
//   }
// }