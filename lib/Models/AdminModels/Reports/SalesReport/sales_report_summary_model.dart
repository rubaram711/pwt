class SalesReportSummaryModel {

  final int? totalOrders;

  final String? gross;

  final String? net;

  final String? discount;

  final String? tax;

  final String? currency;

  final String? note;

  SalesReportSummaryModel({

    this.totalOrders,

    this.gross,

    this.net,

    this.discount,

    this.tax,

    this.currency,

    this.note,
  });

  factory SalesReportSummaryModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return SalesReportSummaryModel();
    }

    return SalesReportSummaryModel(

      totalOrders:
      json['total_orders'],

      gross: json['gross'],

      net: json['net'],

      discount:
      json['discount'],

      tax: json['tax'],

      currency:
      json['currency'],

      note: json['note'],
    );
  }
}