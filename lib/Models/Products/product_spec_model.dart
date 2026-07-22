class ProductSpecModel {

  final int? id;
  final String? label;
  final String? value;
  final int? displayOrder;

  ProductSpecModel({
    this.id,
    this.label,
    this.value,
    this.displayOrder,
  });

  factory ProductSpecModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return ProductSpecModel(
      id: json['id'],
      label: json['label'],
      value: json['value'],
      displayOrder: json['display_order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'value': value,
      'display_order': displayOrder,
    };
  }
}