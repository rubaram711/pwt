class DashboardMachinesModel {

  final int? totalActive;

  final int? dueMaintenance30d;

  DashboardMachinesModel({
    this.totalActive,
    this.dueMaintenance30d,
  });

  factory DashboardMachinesModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return DashboardMachinesModel(

      totalActive:
      json['total_active'],

      dueMaintenance30d:
      json['due_maintenance_30d'],
    );
  }
}