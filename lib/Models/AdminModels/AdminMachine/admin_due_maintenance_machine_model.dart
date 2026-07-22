class AdminDueMaintenanceMachineModel {

  final int? id;

  final String? serialNumber;

  final Map<String, dynamic>? customer;

  final String? nextMaintenanceDueAt;

  final int? daysUntilDue;

  AdminDueMaintenanceMachineModel({
    this.id,
    this.serialNumber,
    this.customer,
    this.nextMaintenanceDueAt,
    this.daysUntilDue,
  });

  factory AdminDueMaintenanceMachineModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminDueMaintenanceMachineModel(

      id: json['id'],

      serialNumber:
      json['serial_number'],

      customer:
      json['customer'],

      nextMaintenanceDueAt:
      json['next_maintenance_due_at'],

      daysUntilDue:
      json['days_until_due'],
    );
  }
}