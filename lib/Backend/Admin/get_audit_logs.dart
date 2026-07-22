import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../const/urls.dart';
import '../../Models/AdminModels/AuditLogs/audit_log_model.dart';

Future<
    ApiResponse<
        PaginatedResponse<
            AuditLogModel
        >
    >
> getAuditLogs({

  int page = 1,

  int perPage = 50,

  int? actorId,

  String? action,

  String? logName,

  String? event,

  String? subjectType,

  int? subjectId,

  String? dateFrom,

  String? dateTo,

  String? search,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<AuditLogModel>(

    request: () => di.get(

      kAdminAuditLogsUrl,

      queryParameters: {

        'page': page,

        'per_page': perPage,

        if (actorId != null)
          'actor_id': actorId,

        if (action != null)
          'action': action,

        if (logName != null)
          'log_name': logName,

        if (event != null)
          'event': event,

        if (subjectType != null)
          'subject_type':
          subjectType,

        if (subjectId != null)
          'subject_id':
          subjectId,

        if (dateFrom != null)
          'date_from': dateFrom,

        if (dateTo != null)
          'date_to': dateTo,

        if (search != null)
          'search': search,
      },
    ),

    itemParser: (item) =>
        AuditLogModel.fromJson(item),
  );
}