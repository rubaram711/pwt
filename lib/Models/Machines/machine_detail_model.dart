import 'machines_model.dart';

class MachineDetailModel {
  final int id;
  final String publicId;
  final String serialNumber;
  final MachineProductModel product;
  final MachineDetailAddress? address;
  final String? installedAt;
  final int? filterChangeIntervalMonths;
  final String? nextMaintenanceDueAt;
  final bool isActive;
  final String term;
  final String status;
  final bool needsMaintenance;
  final bool canRequestMaintenance;
  final int openRequestsCount;
  final int totalLogsCount;
  final List<MaintenanceLog> maintenanceLogs;
  final String? notes;

  MachineDetailModel({
    required this.id,
    required this.publicId,
    required this.serialNumber,
    required this.product,
    this.address,
    this.installedAt,
    this.filterChangeIntervalMonths,
    this.nextMaintenanceDueAt,
    required this.isActive,
    required this.term,
    required this.status,
    required this.needsMaintenance,
    required this.canRequestMaintenance,
    required this.openRequestsCount,
    required this.totalLogsCount,
    required this.maintenanceLogs,
    this.notes,
  });

  factory MachineDetailModel.fromJson(Map<String, dynamic> json) {
    return MachineDetailModel(
      id: json['id'] ?? 0,
      publicId: json['public_id']?.toString() ?? '',
      serialNumber: json['serial_number']?.toString() ?? '',
      product: MachineProductModel.fromJson(json['product'] as Map<String, dynamic>? ?? {}),
      address: json['address'] != null
          ? MachineDetailAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      installedAt: json['installed_at']?.toString(),
      filterChangeIntervalMonths: json['filter_change_interval_months'] as int?,
      nextMaintenanceDueAt: json['next_maintenance_due_at']?.toString(),
      isActive: json['is_active'] ?? true,
      term: json['term']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      needsMaintenance: json['needs_maintenance'] ?? false,
      canRequestMaintenance: json['can_request_maintenance'] ?? false,
      openRequestsCount: json['open_requests_count'] ?? 0,
      totalLogsCount: json['total_logs_count'] ?? 0,
      maintenanceLogs: json['maintenance_logs'] != null
          ? (json['maintenance_logs'] as List)
              .map((e) => MaintenanceLog.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      notes: json['notes']?.toString(),
    );
  }
}

class MachineDetailAddress {
  final String? label;
  final String? line1;
  final String? city;
  final String? postalCode;
  final String? countryName;
  final String? recipientName;

  MachineDetailAddress({
    this.label,
    this.line1,
    this.city,
    this.postalCode,
    this.countryName,
    this.recipientName,
  });

  factory MachineDetailAddress.fromJson(Map<String, dynamic> json) {
    final country = json['country'] as Map<String, dynamic>?;
    return MachineDetailAddress(
      label: json['label']?.toString(),
      line1: json['line1']?.toString(),
      city: json['city']?.toString(),
      postalCode: json['postal_code']?.toString(),
      countryName: country?['name']?.toString(),
      recipientName: json['recipient_name']?.toString(),
    );
  }

  String get displayLine {
    final parts = [line1, city, countryName].where((s) => s != null && s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : label ?? '—';
  }
}

class MaintenanceLog {
  final int id;
  final String? scheduledAt;
  final String? completedAt;
  final String status;
  final String? notes;

  MaintenanceLog({
    required this.id,
    this.scheduledAt,
    this.completedAt,
    required this.status,
    this.notes,
  });

  factory MaintenanceLog.fromJson(Map<String, dynamic> json) => MaintenanceLog(
    id: json['id'] ?? 0,
    scheduledAt: json['scheduled_at']?.toString(),
    completedAt: json['completed_at']?.toString(),
    status: json['status']?.toString() ?? '',
    notes: json['notes']?.toString(),
  );
}
