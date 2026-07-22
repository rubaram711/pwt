class NotificationModel {
  final int? id;
  final String? publicId;
  final String? type;
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? readAt;
  final String? createdAt;

  NotificationModel({
    this.id,
    this.publicId,
    this.type,
    this.title,
    this.body,
    this.data,
    this.actionUrl,
    this.readAt,
    this.createdAt,
  });

  factory NotificationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return NotificationModel(
      id: json['id'],
      publicId: json['public_id'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      actionUrl: json['action_url'],
      readAt: json['read_at'],
      createdAt: json['created_at'],
    );
  }
}

class NotificationReadModel {
  final int? id;
  final String? readAt;

  NotificationReadModel({
    this.id,
    this.readAt,
  });

  factory NotificationReadModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return NotificationReadModel(
      id: json['id'],
      readAt: json['read_at'],
    );
  }
}

class ReadAllNotificationsModel {
  final int? updatedCount;

  ReadAllNotificationsModel({
    this.updatedCount,
  });

  factory ReadAllNotificationsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ReadAllNotificationsModel(
      updatedCount: json['updated_count'],
    );
  }
}