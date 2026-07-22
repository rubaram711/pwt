import '../../../Models/translation_model.dart';

class AdminProductSpecModel {

  final int? id;

  final TranslationModel? label;

  final TranslationModel? value;

  final int? displayOrder;

  AdminProductSpecModel({
    this.id,
    this.label,
    this.value,
    this.displayOrder,
  });

  factory AdminProductSpecModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminProductSpecModel(

      id: json['id'],

      label:
      json['label'] != null

          ? TranslationModel.fromJson(
        json['label'],
      )

          : null,

      value:
      json['value'] != null

          ? TranslationModel.fromJson(
        json['value'],
      )

          : null,

      displayOrder:
      json['display_order'],
    );
  }
}