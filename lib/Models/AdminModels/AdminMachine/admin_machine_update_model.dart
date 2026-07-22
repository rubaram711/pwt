class AdminMachineUpdateModel {

  final int? id;

  final String? serialNumber;

  final int? filterChangeIntervalMonths;

  final String? nextMaintenanceDueAt;

  AdminMachineUpdateModel({
    this.id,
    this.serialNumber,
    this.filterChangeIntervalMonths,
    this.nextMaintenanceDueAt,
  });

  factory AdminMachineUpdateModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminMachineUpdateModel(

      id: json['id'],

      serialNumber:
      json['serial_number'],

      filterChangeIntervalMonths:
      json['filter_change_interval_months'],

      nextMaintenanceDueAt:
      json['next_maintenance_due_at'],
    );
  }
}