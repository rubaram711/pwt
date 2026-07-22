import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/OrderModel/admin_order_status_update_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminOrderStatusUpdateModel
    >
> updateAdminOrderStatus({

  required int orderId,

  required String status,

  String? note,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminOrderStatusUpdateModel>(

    request: () => di.patch(

      '$kAdminOrdersUrl/$orderId/status',

      data: {

        'status': status,

        if (note != null)
          'note': note,
      },
    ),

    parser: (data) =>
        AdminOrderStatusUpdateModel
            .fromJson(data),
  );
}