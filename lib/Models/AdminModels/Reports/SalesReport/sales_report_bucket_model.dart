class SalesReportBucketModel {

  final String? date;

  final int? count;

  final String? gross;

  final String? net;

  final String? tax;

  final String? discount;

  SalesReportBucketModel({

    this.date,

    this.count,

    this.gross,

    this.net,

    this.tax,

    this.discount,
  });

  factory SalesReportBucketModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return SalesReportBucketModel();
    }

    return SalesReportBucketModel(

      date: json['date'],

      count: json['count'],

      gross: json['gross'],

      net: json['net'],

      tax: json['tax'],

      discount:
      json['discount'],
    );
  }
}