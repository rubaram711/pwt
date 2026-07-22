import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Support/admin_support_ticket_update_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminSupportTicketUpdateModel
    >
> updateAdminSupportTicket({

  required int ticketId,

  String? status,

  String? priority,

  int? assignedToUserId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminSupportTicketUpdateModel

  >(

    request: () => di.patch(

      '$kAdminSupportTicketsUrl/$ticketId',

      data: {

        if (status != null)
          'status': status,

        if (priority != null)
          'priority': priority,

        if (assignedToUserId != null)
          'assigned_to_user_id':
          assignedToUserId,
      },
    ),

    parser: (data) =>
        AdminSupportTicketUpdateModel
            .fromJson(data),
  );
}