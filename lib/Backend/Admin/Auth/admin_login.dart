import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Auth/admin_auth_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';
import '../../../myWeb2/state/app_state.dart';

Future<ApiResponse<AdminAuthResponseModel>>
adminLogin({

  required String email,
  required String password,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<AdminAuthResponseModel>(

    request: () => di.post(

      kAdminLoginUrl,

      data: {

        'email': email,

        'password': password,
      },
    ),

    parser: (data) =>
        AdminAuthResponseModel
            .fromJson(data),
  );
}