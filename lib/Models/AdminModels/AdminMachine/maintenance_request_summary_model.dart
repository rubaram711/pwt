class MaintenanceRequestSummaryModel {

  final int? id;

  final String? status;

  final String? createdAt;

  MaintenanceRequestSummaryModel({
    this.id,
    this.status,
    this.createdAt,
  });

  factory MaintenanceRequestSummaryModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return MaintenanceRequestSummaryModel(
      id: json['id'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}