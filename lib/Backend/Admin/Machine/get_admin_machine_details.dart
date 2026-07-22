import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminMachine/admin_machine_details_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminMachineDetailsModel
    >
> getAdminMachineDetails({

  required int machineId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<
      AdminMachineDetailsModel>(

    request: () => di.get(

      '$kAdminMachinesUrl/$machineId',
    ),

    parser: (data) =>
        AdminMachineDetailsModel
            .fromJson(data),
  );
}