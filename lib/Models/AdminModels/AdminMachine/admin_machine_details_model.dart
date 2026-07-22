import '../admin_machine_and_maintenance_customer_model.dart';
import 'admin_machine_product_model.dart';
import 'maintenance_log_model.dart';
import 'maintenance_request_summary_model.dart';

class AdminMachineDetailsModel {

  final int? id;
  final String? publicId;
  final String? serialNumber;

  final AdminMachineAndMaintenanceCustomerModel? customer;
  final AdminMachineProductModel? product;

  final String? installedAt;

  final List<MaintenanceLogModel> maintenanceLogs;

  final List<MaintenanceRequestSummaryModel>
  maintenanceRequests;

  AdminMachineDetailsModel({
    this.id,
    this.publicId,
    this.serialNumber,
    this.customer,
    this.product,
    this.installedAt,
    required this.maintenanceLogs,
    required this.maintenanceRequests,
  });

  factory AdminMachineDetailsModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminMachineDetailsModel(

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

      installedAt: json['installed_at'],

      maintenanceLogs:
      json['maintenance_logs'] != null
          ? List<MaintenanceLogModel>.from(
        json['maintenance_logs'].map(
              (x) =>
              MaintenanceLogModel.fromJson(x),
        ),
      )
          : [],

      maintenanceRequests:
      json['maintenance_requests'] != null
          ? List<
          MaintenanceRequestSummaryModel>.from(
        json['maintenance_requests'].map(
              (x) =>
              MaintenanceRequestSummaryModel
                  .fromJson(x),
        ),
      )
          : [],
    );
  }
}