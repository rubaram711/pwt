class OrdersReportSummaryModel {

  final int? pending;

  final int? confirmed;

  final int? completed;

  OrdersReportSummaryModel({

    this.pending,

    this.confirmed,

    this.completed,
  });

  factory OrdersReportSummaryModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return OrdersReportSummaryModel();
    }

    return OrdersReportSummaryModel(

      pending: json['pending'],

      confirmed:
      json['confirmed'],

      completed:
      json['completed'],
    );
  }
}