import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/Machines/machine_detail_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../Services/dio_service.dart';
import '../../const/urls.dart';

Future<ApiResponse<MachineDetailModel>> getMachineDetail(int id) async {
final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<MachineDetailModel>(
    request: () => di.get(
      '$kMachinesUrl/$id',
    ),
    parser: (data) => MachineDetailModel.fromJson(data),
  );
}