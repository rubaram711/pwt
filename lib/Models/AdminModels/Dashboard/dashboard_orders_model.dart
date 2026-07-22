class DashboardOrdersModel {

  final int? pending;
  final int? confirmed;
  final int? scheduled;
  final int? outForDelivery;
  final int? installed;
  final int? completed;
  final int? cancelled;
  final int? totalThisMonth;

  DashboardOrdersModel({
    this.pending,
    this.confirmed,
    this.scheduled,
    this.outForDelivery,
    this.installed,
    this.completed,
    this.cancelled,
    this.totalThisMonth,
  });

  factory DashboardOrdersModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return DashboardOrdersModel(

      pending: json['pending'],

      confirmed: json['confirmed'],

      scheduled: json['scheduled'],

      outForDelivery:
      json['out_for_delivery'],

      installed: json['installed'],

      completed: json['completed'],

      cancelled: json['cancelled'],

      totalThisMonth:
      json['total_this_month'],
    );
  }
}