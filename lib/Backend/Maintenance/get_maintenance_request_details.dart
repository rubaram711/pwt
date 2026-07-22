import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/Maintenance/maintenance_detail_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../Services/dio_service.dart';
import '../../const/urls.dart';

Future<ApiResponse<MaintenanceDetailModel>> getMaintenanceDetail(int id) async {
final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<MaintenanceDetailModel>(
    request: () => di.get(
      '$kMaintenanceUrl/$id',
    ),
    parser: (data) => MaintenanceDetailModel.fromJson(data),
  );
}