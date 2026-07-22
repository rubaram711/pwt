class RemoveProductImageResponseModel {

  final int? id;

  final int? imagesCount;

  RemoveProductImageResponseModel({
    this.id,
    this.imagesCount,
  });

  factory RemoveProductImageResponseModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return RemoveProductImageResponseModel(

      id: json['id'],

      imagesCount:
      json['images_count'],
    );
  }
}