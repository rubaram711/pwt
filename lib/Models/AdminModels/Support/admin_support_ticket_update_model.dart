import 'support_assigned_to_model.dart';

class AdminSupportTicketUpdateModel {

  final int? id;

  final String? status;

  final String? priority;

  final SupportAssignedToModel?
  assignedTo;

  AdminSupportTicketUpdateModel({

    this.id,

    this.status,

    this.priority,

    this.assignedTo,
  });

  factory
  AdminSupportTicketUpdateModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {

      return
        AdminSupportTicketUpdateModel();
    }

    return
      AdminSupportTicketUpdateModel(

        id: json['id'],

        status: json['status'],

        priority: json['priority'],

        assignedTo:
        SupportAssignedToModel
            .fromJson(
          json['assigned_to'],
        ),
      );
  }
}