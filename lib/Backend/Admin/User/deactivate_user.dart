import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/UserModels/deactivate_user_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        DeactivateUserResponseModel
    >
> deactivateUser({

  required int userId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      DeactivateUserResponseModel>(

    request: () => di.delete(
      '$kAdminUsersUrl/$userId',
    ),

    parser: (data) =>
        DeactivateUserResponseModel
            .fromJson(data),
  );
}