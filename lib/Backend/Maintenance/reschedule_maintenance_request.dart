import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../Models/Maintenance/maintenance_detail_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<MaintenanceDetailModel>> rescheduleMaintenance({
  required int id,
  required String preferredDate,
  required String timeSlot,
}) async {
  print('[rescheduleMaintenance] POST $kMaintenanceUrl/$id/reschedule');
  print('[rescheduleMaintenance] body: preferred_date=$preferredDate time_slot=$timeSlot');

  final dio.Dio di = AppState.instance.dioService.dio;
  final res = await ApiHandler.handleRequest<MaintenanceDetailModel>(
    request: () => di.post(
      '$kMaintenanceUrl/$id/reschedule',
      data: {
        'preferred_date': preferredDate,
        'preferred_time': timeSlot,
      },
    ),
    parser: (data) => MaintenanceDetailModel.fromJson(data),
  );

  print('[rescheduleMaintenance] success=${res.success} message=${res.message}');
  if (res.data != null) {
    print('[rescheduleMaintenance] id=${res.data!.id} status=${res.data!.status} preferredDate=${res.data!.preferredDate} preferredTime=${res.data!.preferredTime}');
  }
  return res;
}
