import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Support/admin_support_ticket_details_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminSupportTicketDetailsModel
    >
> getAdminSupportTicket({

  required int ticketId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminSupportTicketDetailsModel

  >(

    request: () => di.get(

      '$kAdminSupportTicketsUrl/$ticketId',
    ),

    parser: (data) =>
        AdminSupportTicketDetailsModel
            .fromJson(data),
  );
}