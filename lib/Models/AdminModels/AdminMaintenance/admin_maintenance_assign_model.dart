import 'maintenance_assigned_to_model.dart';

class AdminMaintenanceAssignModel {

  final int? id;

  final String? status;

  final MaintenanceAssignedToModel?
  assignedTo;

  AdminMaintenanceAssignModel({
    this.id,
    this.status,
    this.assignedTo,
  });

  factory AdminMaintenanceAssignModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminMaintenanceAssignModel();
    }

    return AdminMaintenanceAssignModel(

      id: json['id'],

      status: json['status'],

      assignedTo:
      MaintenanceAssignedToModel
          .fromJson(
        json['assigned_to'],
      ),
    );
  }
}