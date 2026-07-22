class DashboardCustomersModel {

  final int? newThisMonth;

  final int? totalActive;

  DashboardCustomersModel({
    this.newThisMonth,
    this.totalActive,
  });

  factory DashboardCustomersModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return DashboardCustomersModel(

      newThisMonth:
      json['new_this_month'],

      totalActive:
      json['total_active'],
    );
  }
}