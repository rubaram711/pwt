import 'maintenance_request_model.dart';

class MaintenanceDetailModel {
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
  final String? assignedTo;
  final List<dynamic> media;
  final List<dynamic> statusHistory;

  MaintenanceDetailModel({
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
    this.assignedTo,
    required this.media,
    required this.statusHistory,
  });

  factory MaintenanceDetailModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceDetailModel(
      id: json['id'],
      publicId: json['public_id'],
      displayName: json['display_name']?.toString(),
      issueType: json['issue_type'],
      description: json['description'],
      status: json['status'],
      priority: json['priority'],
      preferredDate: json['preferred_date'],
      preferredTime: json['preferred_time']?.toString(),
      machine: MachineMiniModel.fromJson(json['machine']),
      assignedTo: json['assigned_to'],
      media: json['media'] ?? [],
      statusHistory: json['status_history'] ?? [],
    );
  }
}