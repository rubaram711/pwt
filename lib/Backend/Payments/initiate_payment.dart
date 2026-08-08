import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../Models/Payments/payment_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<PaymentModel>> initiatePayment({
  required int orderId,
  required String paymentMethod,
  int? paymentCardId,
  String? paymentMethodId,
  String? idempotencyKey,
}) async {
  print('[initiatePayment] POST $kPaymentsInitiateUrl');
  print('[initiatePayment] body: orderId=$orderId paymentMethod=$paymentMethod paymentCardId=$paymentCardId paymentMethodId=$paymentMethodId idempotencyKey=$idempotencyKey');

  final dio.Dio di = AppState.instance.dioService.dio;

  final res = await ApiHandler.handleRequest<PaymentModel>(
    request: () async {
      try {
        final response = await di.post(
          kPaymentsInitiateUrl,
          data: {
            'order_id': orderId,
            'payment_method': paymentMethod,
            'mode':"payment_intent",
            if (paymentCardId != null) 'payment_card_id': paymentCardId,
            if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
          },
          options: idempotencyKey != null
              ? dio.Options(headers: {'Idempotency-Key': idempotencyKey})
              : null,
        );
        print('[initiatePayment] RAW response (${response.statusCode}): ${response.data}');
        return response;
      } on dio.DioException catch (e) {
        print('[initiatePayment] RAW error response (${e.response?.statusCode}): ${e.response?.data}');
        rethrow;
      }
    },
    parser: (data) => PaymentModel.fromJson(data),
  );

  print('[initiatePayment] success=${res.success} message=${res.message}');
  if (res.data != null) {
    print('[initiatePayment] paymentId=${res.data!.paymentId} status=${res.data!.status} amount=${res.data!.amount} paymentUrl=${res.data!.paymentUrl} gateway=${res.data!.gateway}');
  }
  return res;
}
