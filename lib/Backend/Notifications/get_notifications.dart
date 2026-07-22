import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/Pagination/paginated_response_model.dart';
import '../../Models/api_response_model.dart';
import '../../Models/notifications_model.dart';
import '../../Services/dio_service.dart';
import '../../Services/paginated_api_handler.dart';
import '../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<NotificationModel>
    >
> getNotifications({

  int page = 1,
  int perPage = 15,
  bool? unreadOnly,
  String? type,
  String? dateFrom,
  String? dateTo,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<NotificationModel>(

    request: () => di.get(

      kNotificationsUrl,

      queryParameters: {

        'page': page,
        'per_page': perPage,

        if (unreadOnly != null)
          'unread_only': unreadOnly,

        if (type != null)
          'type': type,

        if (dateFrom != null)
          'date_from': dateFrom,

        if (dateTo != null)
          'date_to': dateTo,
      },
    ),

    itemParser: (data) =>
        NotificationModel.fromJson(data),
  );
}

//final response = await getNotifications();
//
// final unreadCount =
//     response.data?.meta?['unread_count'];
//
// final items =
//     response.data?.items ?? [];