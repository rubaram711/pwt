import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminMaintenance/admin_maintenance_request_model.dart';
import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<
            AdminMaintenanceRequestModel
        >
    >
> getAdminMaintenanceRequests({

  int page = 1,

  int perPage = 15,

  String? status,

  String? priority,

  String? issueType,

  int? assignedToUserId,

  int? customerId,

  int? machineId,

  String? countryCode,

  String? search,

  String? dateFrom,

  String? dateTo,

  bool? includeTrashed,

  String? sort,

  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler.handleRequest<

      AdminMaintenanceRequestModel

  >(

    request: () => di.get(

      kAdminMaintenanceRequestsUrl,

      queryParameters: {

        'page': page,

        'per_page': perPage,

        if (status != null)
          'status': status,

        if (priority != null)
          'priority': priority,

        if (issueType != null)
          'issue_type': issueType,

        if (assignedToUserId != null)
          'assigned_to_user_id':
          assignedToUserId,

        if (customerId != null)
          'customer_id': customerId,

        if (machineId != null)
          'machine_id': machineId,

        if (countryCode != null)
          'country_code': countryCode,

        if (search != null)
          'search': search,

        if (dateFrom != null)
          'date_from': dateFrom,

        if (dateTo != null)
          'date_to': dateTo,

        if (includeTrashed != null)
          'include_trashed':
          includeTrashed,

        if (sort != null)
          'sort': sort,

        if (order != null)
          'order': order,
      },
    ),

    itemParser: (item) =>
        AdminMaintenanceRequestModel
            .fromJson(item),
  );
}