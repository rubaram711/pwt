class MaintenanceStatusHistoryModel {

  final int? id;

  final String? fromStatus;

  final String? toStatus;

  final String? note;

  final String? createdAt;

  MaintenanceStatusHistoryModel({
    this.id,
    this.fromStatus,
    this.toStatus,
    this.note,
    this.createdAt,
  });

  factory MaintenanceStatusHistoryModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        MaintenanceStatusHistoryModel();
    }

    return MaintenanceStatusHistoryModel(

      id: json['id'],

      fromStatus: json['from_status'],

      toStatus: json['to_status'],

      note: json['note'],

      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'from_status': fromStatus,

      'to_status': toStatus,

      'note': note,

      'created_at': createdAt,
    };
  }
}