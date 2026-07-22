import '../admin_machine_and_maintenance_customer_model.dart';
import 'maintenance_assigned_to_model.dart';
import 'maintenance_machine_model.dart';

class AdminMaintenanceRequestModel {

  final int? id;

  final String? publicId;

  final String? issueType;

  final String? status;

  final String? priority;

  final AdminMachineAndMaintenanceCustomerModel? customer;

  final MaintenanceMachineModel? machine;

  final MaintenanceAssignedToModel? assignedTo;

  final String? createdAt;

  AdminMaintenanceRequestModel({
    this.id,
    this.publicId,
    this.issueType,
    this.status,
    this.priority,
    this.customer,
    this.machine,
    this.assignedTo,
    this.createdAt,
  });

  factory AdminMaintenanceRequestModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return AdminMaintenanceRequestModel();
    }

    return AdminMaintenanceRequestModel(

      id: json['id'],

      publicId: json['public_id'],

      issueType: json['issue_type'],

      status: json['status'],

      priority: json['priority'],

      customer:
      AdminMachineAndMaintenanceCustomerModel.fromJson(
        json['customer'],
      ),

      machine:
      MaintenanceMachineModel.fromJson(
        json['machine'],
      ),

      assignedTo:
      MaintenanceAssignedToModel.fromJson(
        json['assigned_to'],
      ),

      createdAt: json['created_at'],
    );
  }
}