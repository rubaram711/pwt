class AdminMaintenanceSubmitModel {

  final int? id;

  final String? publicId;

  final String? status;

  final String? priority;

  AdminMaintenanceSubmitModel({
    this.id,
    this.publicId,
    this.status,
    this.priority,
  });

  factory AdminMaintenanceSubmitModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return AdminMaintenanceSubmitModel();
    }

    return AdminMaintenanceSubmitModel(

      id: json['id'],

      publicId: json['public_id'],

      status: json['status'],

      priority: json['priority'],
    );
  }
}