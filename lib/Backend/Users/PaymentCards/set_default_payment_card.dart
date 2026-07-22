import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';
import '../../../const/urls.dart';
import '../../../Models/payment_card_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';

Future<ApiResponse<PaymentCard>> setDefaultPaymentCard(int id) async {
  final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<PaymentCard>(
    request: () => di.post('$kPaymentCardsUrl/$id/default'),
    parser: (data) => PaymentCard.fromJson(data),
  );
}
