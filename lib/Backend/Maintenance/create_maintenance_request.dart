import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/Maintenance/maintenance_detail_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../Services/dio_service.dart';
import '../../const/urls.dart';
Future<ApiResponse<MaintenanceDetailModel>> submitMaintenanceRequest({
  required int machineId,
  required String issueType,
  required String description,
  required String preferredDate,
  String? preferredTime,
  List<int>? mediaFileIds,
}) async {
final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<MaintenanceDetailModel>(
    request: () => di.post(
      kMaintenanceUrl,
      data: {
        "machine_id": machineId,
        "issue_type": issueType,
        "description": description,
        "preferred_date": preferredDate,
        if (preferredTime != null) "preferred_time": preferredTime,
        "media_file_ids": mediaFileIds ?? [],
      },
    ),
    parser: (data) => MaintenanceDetailModel.fromJson(data),
  );
}

//curl --location 'http://127.0.0.1:8000/api/v1/maintenance-requests' \
// --header 'Accept: application/json' \
// --header 'Accept-Language: en' \
// --header 'Content-Type: application/json' \
// --data '{
//   "machine_id":230,
//   "issue_type": "filter_change",
//   "description": "Quarterly filter replacement due — water tastes slightly off this week.",
//   "preferred_date": "2026-06-17",
//   "preferred_time ":"14:30",
//   "media_file_ids": []
// }'