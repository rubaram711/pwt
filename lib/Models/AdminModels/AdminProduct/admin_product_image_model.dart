import '../../../Models/translation_model.dart';

class AdminProductImageModel {

  final int? id;

  final String? url;

  final TranslationModel? altText;

  final bool? isPrimary;

  final int? displayOrder;

  AdminProductImageModel({
    this.id,
    this.url,
    this.altText,
    this.isPrimary,
    this.displayOrder,
  });

  factory AdminProductImageModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminProductImageModel(

      id: json['id'],

      url: json['url'],

      altText:
      json['alt_text'] != null

          ? TranslationModel.fromJson(
        json['alt_text'],
      )

          : null,

      isPrimary:
      json['is_primary'],

      displayOrder:
      json['display_order'],
    );
  }
}