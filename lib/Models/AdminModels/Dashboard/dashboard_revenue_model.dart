class DashboardRevenueModel {

  final String? thisMonth;

  final String? currency;

  DashboardRevenueModel({
    this.thisMonth,
    this.currency,
  });

  factory DashboardRevenueModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return DashboardRevenueModel(

      thisMonth:
      json['this_month'],

      currency:
      json['currency'],
    );
  }
}