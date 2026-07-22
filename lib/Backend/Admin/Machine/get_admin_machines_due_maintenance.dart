import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';


import '../../../Models/AdminModels/AdminMachine/admin_due_maintenance_machine_model.dart';
import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<
            AdminDueMaintenanceMachineModel
        >
    >
> getAdminMachinesDueMaintenance({

  int page = 1,
  int perPage = 15,

  int? withinDays,
  int? days,

  String? countryCode,
  int? customerId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler.handleRequest<
      AdminDueMaintenanceMachineModel>(

    request: () => di.get(

      '$kAdminMachinesUrl/due-maintenance',

      queryParameters: {

        'page': page,
        'per_page': perPage,

        if (withinDays != null)
          'within_days': withinDays,

        if (days != null)
          'days': days,

        if (countryCode != null)
          'country_code': countryCode,

        if (customerId != null)
          'customer_id': customerId,
      },
    ),

    itemParser: (item) =>
        AdminDueMaintenanceMachineModel
            .fromJson(item),
  );
}