class SupportMessageModel {

  final int? id;

  final String? senderType;

  final String? body;

  final bool? isInternal;

  final String? createdAt;

  SupportMessageModel({

    this.id,

    this.senderType,

    this.body,

    this.isInternal,

    this.createdAt,
  });

  factory SupportMessageModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return SupportMessageModel();
    }

    return SupportMessageModel(

      id: json['id'],

      senderType: json['sender_type'],

      body: json['body'],

      isInternal: json['is_internal'],

      createdAt: json['created_at'],
    );
  }
}