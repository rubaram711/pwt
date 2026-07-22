class CustomersReportSummaryModel {

  final int? newThisMonth;

  final int? totalActive;

  CustomersReportSummaryModel({

    this.newThisMonth,

    this.totalActive,
  });

  factory
  CustomersReportSummaryModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        CustomersReportSummaryModel();
    }

    return
      CustomersReportSummaryModel(

        newThisMonth:
        json['new_this_month'],

        totalActive:
        json['total_active'],
      );
  }
}