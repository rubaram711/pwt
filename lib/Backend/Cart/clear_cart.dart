import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../Models/Cart/cart_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<CartModel>> clearCart() async {
  print('[clearCart] DELETE $kCartUrl');
  final dio.Dio di = AppState.instance.dioService.dio;
  final res = await ApiHandler.handleRequest<CartModel>(
    request: () => di.delete(kCartUrl),
    parser: (data) => CartModel.fromJson(data),
  );
  print('[clearCart] success=${res.success} message=${res.message}');
  return res;
}
