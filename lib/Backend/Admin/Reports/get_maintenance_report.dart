import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Reports/MaintenanceReport/maintenance_report_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        MaintenanceReportModel
    >
> getMaintenanceReport({

  String? dateFrom,

  String? dateTo,

  String? status,

  int? assignedToUserId,

  String? issueType,

  String? priority,

  String? country,

  int page = 1,

  int perPage = 25,

  String? sort,

  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  try {

    final response = await di.get(

      kAdminReportsMaintenanceUrl,

      queryParameters: {

        if (dateFrom != null)
          'date_from': dateFrom,

        if (dateTo != null)
          'date_to': dateTo,

        if (status != null)
          'status': status,

        if (assignedToUserId != null)
          'assigned_to_user_id':
          assignedToUserId,

        if (issueType != null)
          'issue_type':
          issueType,

        if (priority != null)
          'priority': priority,

        if (country != null)
          'country': country,

        'page': page,

        'per_page': perPage,

        if (sort != null)
          'sort': sort,

        if (order != null)
          'order': order,
      },
    );

    return ApiResponse<
        MaintenanceReportModel>(

      success:
      response.data['success'],

      message:
      response.data['message'],

      code:
      response.data['code'],

      data:
      MaintenanceReportModel
          .fromJson(

        response.data['data'],

        response.data['meta'],
      ),
    );

  } on dio.DioException catch (e) {

    final data = e.response?.data;

    return ApiResponse<
        MaintenanceReportModel>(

      success: false,

      message: data?['message'],

      error: data?['error'],

      code: data?['code'],
    );
  }
}