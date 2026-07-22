import '../admin_machine_and_maintenance_customer_model.dart';
import 'maintenance_assigned_to_model.dart';
import 'maintenance_machine_model.dart';
import 'maintenance_media_model.dart';
import 'maintenance_status_history_model.dart';

class AdminMaintenanceDetailsModel {

  final int? id;

  final String? publicId;

  final String? issueType;

  final String? description;

  final String? status;

  final String? priority;

  final String? internalNotes;

  final AdminMachineAndMaintenanceCustomerModel? customer;

  final MaintenanceMachineModel? machine;

  final MaintenanceAssignedToModel?
  assignedTo;

  final List<MaintenanceMediaModel> media;

  final List<MaintenanceStatusHistoryModel>
  statusHistory;

  AdminMaintenanceDetailsModel({

    this.id,

    this.publicId,

    this.issueType,

    this.description,

    this.status,

    this.priority,

    this.internalNotes,

    this.customer,

    this.machine,

    this.assignedTo,

    this.media = const [],

    this.statusHistory = const [],
  });

  factory AdminMaintenanceDetailsModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminMaintenanceDetailsModel();
    }

    return AdminMaintenanceDetailsModel(

      id: json['id'],

      publicId: json['public_id'],

      issueType: json['issue_type'],

      description: json['description'],

      status: json['status'],

      priority: json['priority'],

      internalNotes:
      json['internal_notes'],

      customer:
      AdminMachineAndMaintenanceCustomerModel
          .fromJson(
        json['customer'],
      ),

      machine:
      MaintenanceMachineModel
          .fromJson(
        json['machine'],
      ),

      assignedTo:
      MaintenanceAssignedToModel
          .fromJson(
        json['assigned_to'],
      ),

      media:
      (json['media'] as List? ?? [])

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