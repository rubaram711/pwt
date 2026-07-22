import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/Pagination/paginated_response_model.dart';
import '../../Models/SupportTicket/support_ticket_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/dio_service.dart';
import '../../Services/paginated_api_handler.dart';
import '../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<SupportTicketModel>
    >
> getSupportTickets({

  int page = 1,
  int perPage = 15,
  String? status,
  String? category,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<SupportTicketModel>(

    request: () => di.get(

      kSupportTicketsUrl,

      queryParameters: {

        'page': page,

        'per_page': perPage,

        if (status != null)
          'status': status,

        if (category != null)
          'category': category,
      },
    ),

    itemParser: (data) =>
        SupportTicketModel.fromJson(data),
  );
}