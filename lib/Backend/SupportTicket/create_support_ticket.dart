import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/SupportTicket/support_ticket_details_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../Services/dio_service.dart';
import '../../const/urls.dart';

Future<ApiResponse<SupportTicketDetailsModel>>
createSupportTicket({

  required String subject,
  required String category,
  required String message,

  int? relatedOrderId,
  int? relatedMachineId,

  List<int>? attachmentFileIds,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<SupportTicketDetailsModel>(

    request: () => di.post(

      kSupportTicketsUrl,

      data: {

        'subject': subject,

        'category': category,

        'message': message,

        if (relatedOrderId != null)
          'related_order_id':
          relatedOrderId,

        if (relatedMachineId != null)
          'related_machine_id':
          relatedMachineId,

        if (attachmentFileIds != null)
          'attachment_file_ids':
          attachmentFileIds,
      },
    ),

    parser: (data) =>
        SupportTicketDetailsModel
            .fromJson(data),
  );
}