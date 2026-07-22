import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/NotificationTemplate/notification_template_update_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Models/translation_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        NotificationTemplateUpdateModel
    >
> updateNotificationTemplate({

  required int templateId,

  TranslationModel? subject,

  TranslationModel? body,

  bool? isActive,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      NotificationTemplateUpdateModel

  >(

    request: () => di.put(

      '$kAdminNotificationTemplatesUrl/$templateId',

      data: {

        if (subject != null)
          'subject':
          subject.toJson(),

        if (body != null)
          'body':
          body.toJson(),

        if (isActive != null)
          'is_active': isActive,
      },
    ),

    parser: (data) =>
        NotificationTemplateUpdateModel
            .fromJson(data),
  );
}