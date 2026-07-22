import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/api_response_model.dart';
import '../../Services/dio_service.dart';
import '../../const/urls.dart';

Future<ApiResponse<void>>
markAllNotificationsAsRead() async {

final dio.Dio di = AppState.instance.dioService.dio;

  try {

    final response = await di.post(
      '$kNotificationsUrl/read-all',
    );

    return ApiResponse<void>(

      success:
      response.data['success'] ?? true,

      message:
      response.data['message'],

      code:
      response.data['code'],
    );

  } on dio.DioException catch (e) {

    final data = e.response?.data;

    return ApiResponse<void>(

      success: false,

      message: data?['message'],

      error: data?['error'],

      code: data?['code'],
    );

  } catch (e) {

    return ApiResponse<void>(

      success: false,

      message: e.toString(),
    );
  }
}

//final unreadCount =
//     response.data?.meta?['unread_count'];