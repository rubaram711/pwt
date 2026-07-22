class SupportMessageModel {

  final int? id;
  final String? senderType;
  final String? body;
  final String? createdAt;

  SupportMessageModel({
    this.id,
    this.senderType,
    this.body,
    this.createdAt,
  });

  factory SupportMessageModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return SupportMessageModel(

      id: json['id'],

      senderType: json['sender_type'],

      body: json['body'],

      createdAt: json['created_at'],
    );
  }
}