import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Support/admin_support_reply_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminSupportReplyModel
    >
> replyToAdminSupportTicket({

  required int ticketId,

  required String body,

  required bool isInternal,

  List<int>? attachmentFileIds,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminSupportReplyModel

  >(

    request: () => di.post(

      '$kAdminSupportTicketsUrl/$ticketId/reply',

      data: {

        'body': body,

        'is_internal': isInternal,

        if (attachmentFileIds != null)
          'attachment_file_ids':
          attachmentFileIds,
      },
    ),

    parser: (data) =>
        AdminSupportReplyModel
            .fromJson(data),
  );
}