import 'audit_log_causer_model.dart';

class AuditLogModel {

  final int? id;

  final String? logName;

  final String? description;

  final String? event;

  final String? subjectType;

  final int? subjectId;

  final AuditLogCauserModel?
  causer;

  final Map<String, dynamic>?
  properties;

  final String? createdAt;

  AuditLogModel({

    this.id,

    this.logName,

    this.description,

    this.event,

    this.subjectType,

    this.subjectId,

    this.causer,

    this.properties,

    this.createdAt,
  });

  factory AuditLogModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return AuditLogModel();
    }

    return AuditLogModel(

      id: json['id'],

      logName:
      json['log_name'],

      description:
      json['description'],

      event: json['event'],

      subjectType:
      json['subject_type'],

      subjectId:
      json['subject_id'],

      causer:
      AuditLogCauserModel
          .fromJson(
        json['causer'],
      ),

      properties:
      json['properties'],

      createdAt:
      json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'log_name': logName,

      'description': description,

      'event': event,

      'subject_type':
      subjectType,

      'subject_id':
      subjectId,

      'causer':
      causer?.toJson(),

      'properties':
      properties,

      'created_at':
      createdAt,
    };
  }
}