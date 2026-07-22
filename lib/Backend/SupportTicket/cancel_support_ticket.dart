import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/SupportTicket/cancel_support_ticket_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../Services/dio_service.dart';
import '../../const/urls.dart';

Future<ApiResponse<CancelSupportTicketModel>>
cancelSupportTicket({

  required int id,
  required String cancellationReason,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<CancelSupportTicketModel>(

    request: () => di.post(

      '$kSupportTicketsUrl/$id/cancel',

      data: {
        'cancellation_reason':
        cancellationReason,
      },
    ),

    parser: (data) =>
        CancelSupportTicketModel
            .fromJson(data),
  );
}