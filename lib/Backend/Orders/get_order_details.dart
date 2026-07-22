import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import 'package:pwt_website/const/urls.dart';

import '../../../Services/dio_service.dart';
import '../../Models/api_response_model.dart';
import '../../Models/Orders/order_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<OrderDetailModel>> getOrderDetail(int orderId) async {
final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<OrderDetailModel>(
    request: () => di.get(
      '$kOrdersUrl/$orderId',
    ),
    parser: (data) => OrderDetailModel.fromJson(data),
  );
}