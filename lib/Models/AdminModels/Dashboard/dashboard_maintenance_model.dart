class DashboardMaintenanceModel {

  final int? pendingRequests;
  final int? dueThisMonth;

  DashboardMaintenanceModel({
    this.pendingRequests,
    this.dueThisMonth,
  });

  factory DashboardMaintenanceModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return DashboardMaintenanceModel(

      pendingRequests:
      json['pending_requests'],

      dueThisMonth:
      json['due_this_month'],
    );
  }
}