import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminMaintenance/admin_maintenance_assign_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminMaintenanceAssignModel
    >
> assignAdminMaintenanceRequest({

  required int requestId,

  required int assignedToUserId,

  String? note,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminMaintenanceAssignModel

  >(

    request: () => di.patch(

      '$kAdminMaintenanceRequestsUrl/$requestId/assign',

      data: {

        'assigned_to_user_id':
        assignedToUserId,

        if (note != null)
          'note': note,
      },
    ),

    parser: (data) =>
        AdminMaintenanceAssignModel
            .fromJson(data),
  );
}