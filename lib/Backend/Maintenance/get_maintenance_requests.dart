import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/Maintenance/maintenance_request_model.dart';
import '../../Models/Pagination/paginated_response_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/dio_service.dart';
import '../../Services/paginated_api_handler.dart';
import '../../const/urls.dart';


Future<ApiResponse<PaginatedResponse<MaintenanceRequestModel>>>
getMaintenanceRequests({
  int page = 1,
  int perPage = 15,
  String? status,
  String? dateFrom,
  String? dateTo,
}) async {
final dio.Dio di = AppState.instance.dioService.dio;

  final response = await di.get(
    kMaintenanceUrl,
    queryParameters: {
      'page': page,
      'per_page': perPage,
      if (status != null) 'status': status,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
    },
  );
  print('[getMaintenanceRequests] body: ${response.data}');
  return PaginatedApiHandler.handleRequest<MaintenanceRequestModel>(
    request: () => di.get(
      kMaintenanceUrl,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      },
    ),
    itemParser: (data) => MaintenanceRequestModel.fromJson(data),
  );
}


//[getMaintenanceRequests] body:
// {success: true, message: Maintenance requests retrieved.,
// data: [{
// id: 2,
// public_id: 9bd984e8-f670-47a7-a0bc-4f73755770a9,
// issue_type: leak, description_excerpt: test test test test test, status: new, priority: medium,
// preferred_date: 2026-06-18, preferred_time: 14:30, time_slot: null,
// machine: {id: 228, public_id: 300333d7-dacf-45d6-8975-59c0aa4dd263,
// serial_number: PENDING-d534e306-0036-4bf9-8978-95accbe4b552-01-01,
// product: {code: test2, name: test2}}, created_at: 2026-06-17T23:08:21+04:00},
// {id: 1, public_id: 98fffdaa-cb6d-4cf8-8423-6465889a5500, issue_type: filter_change, description_excerpt: test note test test, status: new, priority: medium, preferred_date: 2026-06-19, preferred_time: null, time_slot: null, machine: {id: 228, public_id: 300333d7-dacf-45d6-8975-59c0aa4dd263, serial_number: PENDING-d534e306-0036-4bf9-8978-95accbe4b552-01-01, product: {code: test2, name: test2}}, created_at: 2026-06-17T00:49:11+04:00}],
// meta: {pagination: {current_page: 1, last_page: 1, per_