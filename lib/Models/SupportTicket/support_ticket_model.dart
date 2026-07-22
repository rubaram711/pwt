class SupportTicketModel {

  final int? id;
  final String? publicId;
  final String? subject;
  final String? category;
  final String? priority;
  final String? status;
  final String? assignedToFirstName;
  final String? openedAt;
  final String? lastMessageAt;
  final int? unreadMessageCount;

  SupportTicketModel({
    this.id,
    this.publicId,
    this.subject,
    this.category,
    this.priority,
    this.status,
    this.assignedToFirstName,
    this.openedAt,
    this.lastMessageAt,
    this.unreadMessageCount,
  });

  factory SupportTicketModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return SupportTicketModel(

      id: json['id'],

      publicId: json['public_id'],

      subject: json['subject'],

      category: json['category'],

      priority: json['priority'],

      status: json['status'],

      assignedToFirstName:
      json['assigned_to_first_name'],

      openedAt: json['opened_at'],

      lastMessageAt:
      json['last_message_at'],

      unreadMessageCount:
      json['unread_message_count'],
    );
  }
}




