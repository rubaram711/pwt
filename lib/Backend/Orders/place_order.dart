import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../Models/Orders/order_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<OrderDetailModel>> placeOrder({
  required List<Map<String, dynamic>> items,
  String? customerName,
  String? customerEmail,
  String? customerPhone,
  int? deliveryAddressId,
  String? deliveryDate,
  String? deliveryTimeSlot,
  required String term,
  required String paymentMethod,
  String? stripePaymentMethodId,
  String? promoCode,
  String? notes,
}) async {
  print('[placeOrder] POST $kOrdersUrl');
  print('[placeOrder] body: items=${items.length} $items');
  print('[placeOrder] customerName=$customerName email=$customerEmail phone=$customerPhone');
  print('[placeOrder] term=$term paymentMethod=$paymentMethod deliveryAddressId=$deliveryAddressId');
  print('[placeOrder] deliveryDate=$deliveryDate deliveryTimeSlot=$deliveryTimeSlot promoCode=$promoCode notes=$notes');

  final dio.Dio di = AppState.instance.dioService.dio;

  final res = await ApiHandler.handleRequest<OrderDetailModel>(
    request: () => di.post(
      kOrdersUrl,
      data: {
        'items': items,
        if (customerName != null) 'customer_name': customerName,
        if (customerEmail != null) 'customer_email': customerEmail,
        if (customerPhone != null) 'customer_phone': customerPhone,
        if (deliveryAddressId != null) 'delivery_address_id': deliveryAddressId,
        if (deliveryDate != null) 'delivery_date': deliveryDate,
        if (deliveryTimeSlot != null) 'delivery_time_slot': deliveryTimeSlot,
        'term': term,
        'payment_method': paymentMethod,
        if (stripePaymentMethodId != null) 'stripe_payment_method_id': stripePaymentMethodId,
        if (promoCode != null) 'promo_code': promoCode,
        if (notes != null) 'notes': notes,
      },
    ),
    parser: (data) => OrderDetailModel.fromJson(data),
  );

  print('[placeOrder] success=${res.success} message=${res.message}');
  if (res.data != null) {
    print('[placeOrder] orderId=${res.data!.id} status=${res.data!.status} total=${res.data!.totalAmount}');
  }
  return res;
}
