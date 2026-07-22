class AdminCancelOrderModel {

  final int? id;

  final String? status;

  final String? cancellationReason;

  AdminCancelOrderModel({
    this.id,
    this.status,
    this.cancellationReason,
  });

  factory AdminCancelOrderModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminCancelOrderModel(

      id: json['id'],

      status: json['status'],

      cancellationReason:
      json['cancellation_reason'],
    );
  }
}