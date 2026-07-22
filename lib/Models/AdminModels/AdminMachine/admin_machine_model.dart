import '../admin_machine_and_maintenance_customer_model.dart';
import 'admin_machine_product_model.dart';

class AdminMachineModel {

  final int? id;
  final String? publicId;
  final String? serialNumber;

  final AdminMachineAndMaintenanceCustomerModel? customer;
  final AdminMachineProductModel? product;

  final String? countryCode;

  final String? installedAt;
  final String? nextMaintenanceDueAt;

  final bool? isActive;

  final int? daysUntilDue;

  AdminMachineModel({
    this.id,
    this.publicId,
    this.serialNumber,
    this.customer,
    this.product,
    this.countryCode,
    this.installedAt,
    this.nextMaintenanceDueAt,
    this.isActive,
    this.daysUntilDue,
  });

  factory AdminMachineModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminMachineModel(

      id: json['id'],

      publicId: json['public_id'],

      serialNumber: json['serial_number'],

      customer: json['customer'] != null
          ? AdminMachineAndMaintenanceCustomerModel.fromJson(
        json['customer'],
      )
          : null,

      product: json['product'] != null
          ? AdminMachineProductModel.fromJson(
        json['product'],
      )
          : null,

      countryCode: json['country_code'],

      installedAt: json['installed_at'],

      nextMaintenanceDueAt:
      json['next_maintenance_due_at'],

      isActive: json['is_active'],

      daysUntilDue: json['days_until_due'],
    );
  }
}