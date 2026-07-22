import 'package:pwt_website/Models/AdminModels/admin_machine_and_maintenance_customer_model.dart';

import 'support_assigned_to_model.dart';

class AdminSupportTicketModel {

  final int? id;

  final String? publicId;

  final String? subject;

  final String? category;

  final String? priority;

  final String? status;

  final SupportAssignedToModel?
  assignedTo;

  final AdminMachineAndMaintenanceCustomerModel?
  customer;

  final String? lastMessageAt;

  AdminSupportTicketModel({

    this.id,

    this.publicId,

    this.subject,

    this.category,

    this.priority,

    this.status,

    this.assignedTo,

    this.customer,

    this.lastMessageAt,
  });

  factory AdminSupportTicketModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return AdminSupportTicketModel();
    }

    return AdminSupportTicketModel(

      id: json['id'],

      publicId: json['public_id'],

      subject: json['subject'],

      category: json['category'],

      priority: json['priority'],

      status: json['status'],

      assignedTo:
      SupportAssignedToModel
          .fromJson(
        json['assigned_to'],
      ),

      customer:
      AdminMachineAndMaintenanceCustomerModel
          .fromJson(
        json['customer'],
      ),

      lastMessageAt:
      json['last_message_at'],
    );
  }
}