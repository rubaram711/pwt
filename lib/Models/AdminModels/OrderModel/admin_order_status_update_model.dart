class AdminOrderStatusUpdateModel {

  final int? id;

  final String? status;

  final String? previousStatus;

  AdminOrderStatusUpdateModel({
    this.id,
    this.status,
    this.previousStatus,
  });

  factory AdminOrderStatusUpdateModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminOrderStatusUpdateModel(

      id: json['id'],

      status: json['status'],

      previousStatus:
      json['previous_status'],
    );
  }
}