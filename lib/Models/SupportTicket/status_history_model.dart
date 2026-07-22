class StatusHistoryModel {

  final String? fromStatus;
  final String? toStatus;
  final String? actorType;
  final String? createdAt;

  StatusHistoryModel({
    this.fromStatus,
    this.toStatus,
    this.actorType,
    this.createdAt,
  });

  factory StatusHistoryModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return StatusHistoryModel(

      fromStatus: json['from_status'],

      toStatus: json['to_status'],

      actorType: json['actor_type'],

      createdAt: json['created_at'],
    );
  }
}