import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/api_response_model.dart';
import '../../Models/notifications_model.dart';
import '../../Services/api_handler.dart';
import '../../Services/dio_service.dart';
import '../../const/urls.dart';

Future<ApiResponse<NotificationReadModel>>
markNotificationAsRead({
  required int id,
}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<NotificationReadModel>(

    request: () => di.patch(
      '$kNotificationsUrl/$id/read',
    ),

    parser: (data) =>
        NotificationReadModel.fromJson(
          data,
        ),
  );
}