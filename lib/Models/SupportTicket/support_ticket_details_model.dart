import 'support_attachment_model.dart';
import 'support_message_model.dart';
import 'status_history_model.dart';
import 'related_order_model.dart';

class SupportTicketDetailsModel {

  final int? id;
  final String? publicId;
  final String? subject;
  final String? category;
  final String? priority;
  final String? status;

  final String? assignedToFirstName;

  final List<SupportMessageModel>?
  messages;

  final List<SupportAttachmentModel>?
  attachments;

  final List<StatusHistoryModel>?
  statusHistory;

  final RelatedOrderModel? relatedOrder;

  SupportTicketDetailsModel({
    this.id,
    this.publicId,
    this.subject,
    this.category,
    this.priority,
    this.status,
    this.assignedToFirstName,
    this.messages,
    this.attachments,
    this.statusHistory,
    this.relatedOrder,
  });

  factory SupportTicketDetailsModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return SupportTicketDetailsModel(

      id: json['id'],

      publicId: json['public_id'],

      subject: json['subject'],

      category: json['category'],

      priority: json['priority'],

      status: json['status'],

      assignedToFirstName:
      json['assigned_to_first_name'],

      messages:
      json['messages'] != null

          ? (json['messages'] as List)

          .map(
            (e) =>
            SupportMessageModel
                .fromJson(e),
      )

          .toList()

          : [],

      attachments:
      json['attachments'] != null

          ? (json['attachments'] as List)

          .map(
            (e) =>
            SupportAttachmentModel
                .fromJson(e),
      )

          .toList()

          : [],

      statusHistory:
      json['status_history'] != null

          ? (json['status_history']
      as List)

          .map(
            (e) =>
            StatusHistoryModel
                .fromJson(e),
      )

          .toList()

          : [],

      relatedOrder:
      json['related_order'] != null

          ? RelatedOrderModel.fromJson(
        json['related_order'],
      )

          : null,
    );
  }
}