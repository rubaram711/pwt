import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../Models/Cart/cart_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<CartModel>> getCart() async {
  print('[getCart] GET $kCartUrl');
  final dio.Dio di = AppState.instance.dioService.dio;
  final res = await ApiHandler.handleRequest<CartModel>(
    request: () => di.get(kCartUrl),
    parser: (data) => CartModel.fromJson(data),
  );
  print('[getCart] success=${res.success} message=${res.message} items=${res.data?.items.length}');
  if (res.data != null) {
    for (final item in res.data!.items) {
      print('[getCart]   item: id=${item.id} productId=${item.productId} term=${item.term} qty=${item.quantity} productName=${item.product?.name}');
    }
  }
  return res;
}
