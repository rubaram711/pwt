import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/OrderModel/admin_order_note_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';


Future<
    ApiResponse<AdminOrderNoteModel>
> addAdminOrderNote({

  required int orderId,

  required String note,

  String visibility = 'internal',

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminOrderNoteModel>(

    request: () => di.post(

      '$kAdminOrdersUrl/$orderId/notes',

      data: {

        'note': note,

        'visibility': visibility,
      },
    ),

    parser: (data) =>
        AdminOrderNoteModel
            .fromJson(data),
  );
}