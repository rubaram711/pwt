class CancelSupportTicketModel {

  final int? id;
  final String? status;
  final String? cancellationReason;

  CancelSupportTicketModel({
    this.id,
    this.status,
    this.cancellationReason,
  });

  factory CancelSupportTicketModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return CancelSupportTicketModel(

      id: json['id'],

      status: json['status'],

      cancellationReason:
      json['cancellation_reason'],
    );
  }
}