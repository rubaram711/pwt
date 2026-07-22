import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Support/admin_support_ticket_model.dart';
import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<
            AdminSupportTicketModel
        >
    >
> getAdminSupportTickets({

  int page = 1,

  int perPage = 15,

  String? search,

  String? status,

  String? category,

  String? priority,

  int? assignedToUserId,

  int? customerId,

  String? dateFrom,

  String? dateTo,

  bool? includeTrashed,

  String? sort,

  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<

      AdminSupportTicketModel

  >(

    request: () => di.get(

      kAdminSupportTicketsUrl,

      queryParameters: {

        'page': page,

        'per_page': perPage,

        if (search != null)
          'search': search,

        if (status != null)
          'status': status,

        if (category != null)
          'category': category,

        if (priority != null)
          'priority': priority,

        if (assignedToUserId != null)
          'assigned_to_user_id':
          assignedToUserId,

        if (customerId != null)
          'customer_id': customerId,

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
        AdminSupportTicketModel
            .fromJson(item),
  );
}