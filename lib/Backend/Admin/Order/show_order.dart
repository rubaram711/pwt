import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/OrderModel/admin_order_details_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<ApiResponse<AdminOrderDetailsModel>>
getAdminOrderDetails(
    int orderId,
    ) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminOrderDetailsModel>(

    request: () => di.get(
      '$kAdminOrdersUrl/$orderId',
    ),

    parser: (data) =>
        AdminOrderDetailsModel
            .fromJson(data),
  );
}