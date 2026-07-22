import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/AdminModels/Dashboard/dashboard_response_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../Services/dio_service.dart';
import '../../const/urls.dart';

Future<ApiResponse<AdminDashboardModel>>
getAdminDashboard() async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminDashboardModel>(

    request: () => di.get(
      kAdminDashboardUrl,
    ),

    parser: (data) =>
        AdminDashboardModel
            .fromJson(data),
  );
}