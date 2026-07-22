class NotificationTemplateUpdateModel {

  final int? id;

  final String? key;

  final String? channel;

  final bool? isActive;

  NotificationTemplateUpdateModel({

    this.id,

    this.key,

    this.channel,

    this.isActive,
  });

  factory
  NotificationTemplateUpdateModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {

      return
        NotificationTemplateUpdateModel();
    }

    return
      NotificationTemplateUpdateModel(

        id: json['id'],

        key: json['key'],

        channel:
        json['channel'],

        isActive:
        json['is_active'],
      );
  }
}