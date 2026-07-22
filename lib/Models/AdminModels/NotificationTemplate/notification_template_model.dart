import '../../translation_model.dart';

class NotificationTemplateModel {

  final int? id;

  final String? key;

  final String? channel;

  final TranslationModel?
  subject;

  final TranslationModel?
  body;

  final bool? isActive;

  NotificationTemplateModel({

    this.id,

    this.key,

    this.channel,

    this.subject,

    this.body,

    this.isActive,
  });

  factory NotificationTemplateModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        NotificationTemplateModel();
    }

    return
      NotificationTemplateModel(

        id: json['id'],

        key: json['key'],

        channel:
        json['channel'],

        subject:
        TranslationModel.fromJson(
          json['subject'],
        ),

        body:
        TranslationModel.fromJson(
          json['body'],
        ),

        isActive:
        json['is_active'],
      );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'key': key,

      'channel': channel,

      'subject':
      subject?.toJson(),

      'body':
      body?.toJson(),

      'is_active':
      isActive,
    };
  }
}