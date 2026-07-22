import 'dashboard_customers_model.dart';
import 'dashboard_maintenance_model.dart';
import 'dashboard_machines_model.dart';
import 'dashboard_orders_model.dart';
import 'dashboard_revenue_model.dart';

class AdminDashboardModel {

  final DashboardOrdersModel? orders;

  final DashboardRevenueModel? revenue;

  final DashboardMaintenanceModel? maintenance;

  final DashboardCustomersModel? customers;

  final DashboardMachinesModel? machines;

  AdminDashboardModel({
    this.orders,
    this.revenue,
    this.maintenance,
    this.customers,
    this.machines,
  });

  factory AdminDashboardModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminDashboardModel(

      orders:
      json['orders'] != null

          ? DashboardOrdersModel.fromJson(
        json['orders'],
      )

          : null,

      revenue:
      json['revenue'] != null

          ? DashboardRevenueModel.fromJson(
        json['revenue'],
      )

          : null,

      maintenance:
      json['maintenance'] != null

          ? DashboardMaintenanceModel
          .fromJson(
        json['maintenance'],
      )

          : null,

      customers:
      json['customers'] != null

          ? DashboardCustomersModel
          .fromJson(
        json['customers'],
      )

          : null,

      machines:
      json['machines'] != null

          ? DashboardMachinesModel
          .fromJson(
        json['machines'],
      )

          : null,
    );
  }
}