class RelatedOrderModel {

  final int? id;
  final String? publicId;

  RelatedOrderModel({
    this.id,
    this.publicId,
  });

  factory RelatedOrderModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return RelatedOrderModel(

      id: json['id'],

      publicId: json['public_id'],
    );
  }
}