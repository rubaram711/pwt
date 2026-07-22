class AdminMaintenanceStatusUpdateModel {

  final int? id;

  final String? status;

  final String? previousStatus;

  AdminMaintenanceStatusUpdateModel({
    this.id,
    this.status,
    this.previousStatus,
  });

  factory
  AdminMaintenanceStatusUpdateModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminMaintenanceStatusUpdateModel();
    }

    return
      AdminMaintenanceStatusUpdateModel(

        id: json['id'],

        status: json['status'],

        previousStatus:
        json['previous_status'],
      );
  }
}