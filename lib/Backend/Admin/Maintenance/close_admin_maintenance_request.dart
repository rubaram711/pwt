import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminMaintenance/admin_maintenance_close_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminMaintenanceCloseModel
    >
> closeAdminMaintenanceRequest({

  required int requestId,

  required String resolutionNotes,

  String? completedAt,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminMaintenanceCloseModel

  >(

    request: () => di.post(

      '$kAdminMaintenanceRequestsUrl/$requestId/close',

      data: {

        'resolution_notes':
        resolutionNotes,

        if (completedAt != null)
          'completed_at':
          completedAt,
      },
    ),

    parser: (data) =>
        AdminMaintenanceCloseModel
            .fromJson(data),
  );
}