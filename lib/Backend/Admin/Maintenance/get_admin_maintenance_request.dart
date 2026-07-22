import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminMaintenance/admin_maintenance_details_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminMaintenanceDetailsModel
    >
> getAdminMaintenanceRequest({

  required int requestId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminMaintenanceDetailsModel

  >(

    request: () => di.get(

      '$kAdminMaintenanceRequestsUrl/$requestId',
    ),

    parser: (data) =>
        AdminMaintenanceDetailsModel
            .fromJson(data),
  );
}