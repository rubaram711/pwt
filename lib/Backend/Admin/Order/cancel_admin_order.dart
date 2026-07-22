import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/OrderModel/admin_cancel_order_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';


Future<
    ApiResponse<AdminCancelOrderModel>
> cancelAdminOrder({

  required int orderId,

  required String reason,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminCancelOrderModel>(

    request: () => di.post(

      '$kAdminOrdersUrl/$orderId/cancel',

      data: {
        'reason': reason,
      },
    ),

    parser: (data) =>
        AdminCancelOrderModel
            .fromJson(data),
  );
}