class MaintenanceLogModel {

  final int? id;

  final String? completedAt;

  final String? status;

  MaintenanceLogModel({
    this.id,
    this.completedAt,
    this.status,
  });

  factory MaintenanceLogModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return MaintenanceLogModel(
      id: json['id'],
      completedAt: json['completed_at'],
      status: json['status'],
    );
  }
}