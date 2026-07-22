import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminMaintenance/admin_maintenance_submit_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminMaintenanceSubmitModel
    >
> submitAdminMaintenanceRequest({

  required int userId,

  required int machineId,

  required String issueType,

  required String description,

  required String priority,

  String? preferredDate,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminMaintenanceSubmitModel

  >(

    request: () => di.post(

      kAdminMaintenanceRequestsUrl,

      data: {

        'user_id': userId,

        'machine_id': machineId,

        'issue_type': issueType,

        'description': description,

        'priority': priority,

        if (preferredDate != null)
          'preferred_date':
          preferredDate,
      },
    ),

    parser: (data) =>
        AdminMaintenanceSubmitModel
            .fromJson(data),
  );
}