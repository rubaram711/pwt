class MaintenanceRequestModel {
  final int id;
  final String publicId;
  final String? displayName;
  final String issueType;
  final String description;
  final String status;
  final String priority;
  final String preferredDate;
  final String? preferredTime;
  final MachineMiniModel machine;
  final String createdAt;

  MaintenanceRequestModel({
    required this.id,
    required this.publicId,
    this.displayName,
    required this.issueType,
    required this.description,
    required this.status,
    required this.priority,
    required this.preferredDate,
    this.preferredTime,
    required this.machine,
    required this.createdAt,
  });

  factory MaintenanceRequestModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequestModel(
      id: json['id'],
      publicId: json['public_id'],
      displayName: json['display_name']?.toString(),
      issueType: json['issue_type'],
      description: json['description_excerpt']?.toString() ?? json['description']?.toString() ?? '',
      status: json['status'],
      priority: json['priority'],
      preferredDate: json['preferred_date'],
      preferredTime: json['preferred_time']?.toString(),
      machine: MachineMiniModel.fromJson(json['machine']),
      createdAt: json['created_at'],
    );
  }
}

class MachineMiniModel {
  final int id;
  final String serialNumber;
  final String? displayName;
  final String? productCode;
  final String? productName;

  MachineMiniModel({
    required this.id,
    required this.serialNumber,
    this.displayName,
    this.productCode,
    this.productName,
  });

  factory MachineMiniModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return MachineMiniModel(
      id: json['id'],
      serialNumber: json['serial_number'],
      displayName: (json['display_name'] ?? json['location_label'])?.toString(),
      productCode: product?['code']?.toString(),
      productName: product?['name']?.toString(),
    );
  }
}
