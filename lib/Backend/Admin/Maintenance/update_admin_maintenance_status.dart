import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminMaintenance/admin_maintenance_status_update_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminMaintenanceStatusUpdateModel
    >
> updateAdminMaintenanceStatus({

  required int requestId,

  required String status,

  String? note,

  String? cancellationReason,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminMaintenanceStatusUpdateModel

  >(

    request: () => di.patch(

      '$kAdminMaintenanceRequestsUrl/$requestId/status',

      data: {

        'status': status,

        if (note != null)
          'note': note,

        if (cancellationReason != null)
          'cancellation_reason':
          cancellationReason,
      },
    ),

    parser: (data) =>
        AdminMaintenanceStatusUpdateModel
            .fromJson(data),
  );
}