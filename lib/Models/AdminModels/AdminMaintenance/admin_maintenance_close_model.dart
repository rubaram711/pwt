class AdminMaintenanceCloseModel {

  final int? id;

  final String? status;

  final String? completedAt;

  final String? resolutionNotes;

  AdminMaintenanceCloseModel({
    this.id,
    this.status,
    this.completedAt,
    this.resolutionNotes,
  });

  factory AdminMaintenanceCloseModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        AdminMaintenanceCloseModel();
    }

    return AdminMaintenanceCloseModel(

      id: json['id'],

      status: json['status'],

      completedAt: json['completed_at'],

      resolutionNotes:
      json['resolution_notes'],
    );
  }
}