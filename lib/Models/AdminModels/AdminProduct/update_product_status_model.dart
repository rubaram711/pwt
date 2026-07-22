class UpdateProductStatusModel {

  final int? id;

  final bool? isActive;

  final bool? isFeatured;

  final bool? isQuoteOnly;

  final String? stockStatus;

  UpdateProductStatusModel({
    this.id,
    this.isActive,
    this.isFeatured,
    this.isQuoteOnly,
    this.stockStatus,
  });

  factory UpdateProductStatusModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return UpdateProductStatusModel(

      id: json['id'],

      isActive:
      json['is_active'],

      isFeatured:
      json['is_featured'],

      isQuoteOnly:
      json['is_quote_only'],

      stockStatus:
      json['stock_status'],
    );
  }
}