class AdminSupportReplyModel {

  final int? id;

  final int? ticketId;

  final String? senderType;

  final String? body;

  final bool? isInternal;

  final String? createdAt;

  AdminSupportReplyModel({

    this.id,

    this.ticketId,

    this.senderType,

    this.body,

    this.isInternal,

    this.createdAt,
  });

  factory AdminSupportReplyModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return AdminSupportReplyModel();
    }

    return AdminSupportReplyModel(

      id: json['id'],

      ticketId: json['ticket_id'],

      senderType: json['sender_type'],

      body: json['body'],

      isInternal: json['is_internal'],

      createdAt: json['created_at'],
    );
  }
}