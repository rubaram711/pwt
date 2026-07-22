import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';
import '../../../const/urls.dart';
import '../../../Models/payment_card_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';

Future<ApiResponse<PaymentCard>> updatePaymentCard({
  required int id,
  String? brand,
  String? lastFour,
  String? cardNumberHash,
  String? expiryMonth,
  String? expiryYear,
  String? cardholderName,
  bool? isDefault,
}) async {
  final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<PaymentCard>(
    request: () => di.patch(
      '$kPaymentCardsUrl/$id',
      data: {
        if (brand != null) 'brand': brand,
        if (lastFour != null) 'last_four': lastFour,
        if (cardNumberHash != null) 'card_number_hash': cardNumberHash,
        if (expiryMonth != null) 'expiry_month': expiryMonth,
        if (expiryYear != null) 'expiry_year': expiryYear,
        if (cardholderName != null) 'cardholder_name': cardholderName,
        if (isDefault != null) 'is_default': isDefault,
      },
    ),
    parser: (data) => PaymentCard.fromJson(data),
  );
}
