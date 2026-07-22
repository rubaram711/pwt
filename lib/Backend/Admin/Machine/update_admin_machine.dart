import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminMachine/admin_machine_update_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminMachineUpdateModel
    >
> updateAdminMachine({

  required int machineId,

  int? filterChangeIntervalMonths,

  String? locationLabel,
  String? notes,

  bool? isActive,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<
      AdminMachineUpdateModel>(

    request: () => di.put(

      '$kAdminMachinesUrl/$machineId',

      data: {

        if (filterChangeIntervalMonths != null)
          'filter_change_interval_months':
          filterChangeIntervalMonths,

        if (locationLabel != null)
          'location_label': locationLabel,

        if (notes != null)
          'notes': notes,

        if (isActive != null)
          'is_active': isActive,
      },
    ),

    parser: (data) =>
        AdminMachineUpdateModel
            .fromJson(data),
  );
}