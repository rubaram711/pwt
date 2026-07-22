import '../AdminMaintenance/maintenance_media_model.dart';
import '../AdminMaintenance/maintenance_status_history_model.dart';
import 'support_message_model.dart';

class AdminSupportTicketDetailsModel {

  final int? id;

  final String? publicId;

  final String? subject;

  final String? category;

  final String? status;

  final List<SupportMessageModel>
  messages;

  final List<MaintenanceMediaModel>
  attachments;

  final List<
      MaintenanceStatusHistoryModel
  > statusHistory;

  AdminSupportTicketDetailsModel({

    this.id,

    this.publicId,

    this.subject,

    this.category,

    this.status,

    this.messages = const [],

    this.attachments = const [],

    this.statusHistory = const [],
  });

  factory
  AdminSupportTicketDetailsModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {

      return
        AdminSupportTicketDetailsModel();
    }

    return
      AdminSupportTicketDetailsModel(

        id: json['id'],

        publicId: json['public_id'],

        subject: json['subject'],

        category: json['category'],

        status: json['status'],

        messages:
        (json['messages']
        as List? ?? [])

            .map(
              (e) =>
              SupportMessageModel
                  .fromJson(e),
        )

            .toList(),

        attachments:
        (json['attachments']
        as List? ?? [])

            .map(
              (e) =>
              MaintenanceMediaModel
                  .fromJson(e),
        )

            .toList(),

        statusHistory:
        (json['status_history']
        as List? ?? [])

            .map(
              (e) =>
              MaintenanceStatusHistoryModel
                  .fromJson(e),
        )

            .toList(),
      );
  }
}