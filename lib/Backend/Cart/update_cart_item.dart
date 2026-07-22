import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../Models/Cart/cart_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<CartModel>> updateCartItem(int itemId, {required int quantity}) async {
  print('[updateCartItem] PATCH $kCartItemsUrl/$itemId body={quantity: $quantity}');
  final dio.Dio di = AppState.instance.dioService.dio;
  final res = await ApiHandler.handleRequest<CartModel>(
    request: () => di.patch('$kCartItemsUrl/$itemId', data: {'quantity': quantity}),
    parser: (data) => CartModel.fromJson(data),
  );
  print('[updateCartItem] success=${res.success} message=${res.message} items=${res.data?.items.length}');
  if (res.data != null) {
    for (final item in res.data!.items) {
      print('[updateCartItem]   item: id=${item.id} productId=${item.productId} term=${item.term} qty=${item.quantity}');
    }
  }
  return res;
}
