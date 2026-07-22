class DeleteCategoryResponseModel {

  final int? id;

  final String? deletedAt;

  DeleteCategoryResponseModel({
    this.id,
    this.deletedAt,
  });

  factory DeleteCategoryResponseModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return DeleteCategoryResponseModel(

      id: json['id'],

      deletedAt:
      json['deleted_at'],
    );
  }
}