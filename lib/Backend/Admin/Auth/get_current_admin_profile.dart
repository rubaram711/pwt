import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Auth/current_admin_profile_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<ApiResponse<CurrentAdminProfileModel>>
getCurrentAdminProfile() async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      CurrentAdminProfileModel>(

    request: () => di.get(
      kAdminProfileUrl,
    ),

    parser: (data) =>
        CurrentAdminProfileModel
            .fromJson(data),
  );
}