import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/UserModels/update_user_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        UpdateUserResponseModel
    >
> updateUser({

  required int userId,

  String? name,

  String? email,

  String? locale,

  bool? isActive,

  String? role,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      UpdateUserResponseModel>(

    request: () => di.patch(

      '$kAdminUsersUrl/$userId',

      data: {

        if (name != null)
          'name': name,

        if (email != null)
          'email': email,

        if (locale != null)
          'locale': locale,

        if (isActive != null)
          'is_active': isActive,

        if (role != null)
          'role': role,
      },
    ),

    parser: (data) =>
        UpdateUserResponseModel
            .fromJson(data),
  );
}