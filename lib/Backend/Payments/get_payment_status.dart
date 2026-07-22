import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../Models/Payments/payment_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<PaymentStatusModel>> getPaymentStatus(int paymentId) async {
  print('[getPaymentStatus] GET $kPaymentsUrl/$paymentId/status');

  final dio.Dio di = AppState.instance.dioService.dio;

  final res = await ApiHandler.handleRequest<PaymentStatusModel>(
    request: () => di.get('$kPaymentsUrl/$paymentId/status'),
    parser: (data) => PaymentStatusModel.fromJson(data),
  );

  print('[getPaymentStatus] success=${res.success} message=${res.message}');
  if (res.data != null) {
    print('[getPaymentStatus] status=${res.data!.status} isCaptured=${res.data!.isCaptured} isFailed=${res.data!.isFailed} isPending=${res.data!.isPending} failureReason=${res.data!.failureReason}');
  }
  return res;
}
