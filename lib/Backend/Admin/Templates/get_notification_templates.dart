import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/NotificationTemplate/notification_template_model.dart';
import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<
            NotificationTemplateModel
        >
    >
> getNotificationTemplates({

  int page = 1,

  int perPage = 15,

  String? channel,

  String? key,

  bool? isActive,

  String? sort,

  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<
      NotificationTemplateModel>(

    request: () => di.get(

      kAdminNotificationTemplatesUrl,

      queryParameters: {

        'page': page,

        'per_page': perPage,

        if (channel != null)
          'channel': channel,

        if (key != null)
          'key': key,

        if (isActive != null)
          'is_active': isActive,

        if (sort != null)
          'sort': sort,

        if (order != null)
          'order': order,
      },
    ),

    itemParser: (item) =>
        NotificationTemplateModel
            .fromJson(item),
  );
}