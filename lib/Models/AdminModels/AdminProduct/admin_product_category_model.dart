class AdminProductCategoryModel {

  final int? id;

  final String? name;

  AdminProductCategoryModel({
    this.id,
    this.name,
  });

  factory AdminProductCategoryModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminProductCategoryModel(

      id: json['id'],

      name: json['name'],
    );
  }
}