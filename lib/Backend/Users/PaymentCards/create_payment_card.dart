import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';
import '../../../const/urls.dart';
import '../../../Models/payment_card_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';

Future<ApiResponse<PaymentCard>> createPaymentCard({
  required String brand,
  required String lastFour,
  required String cardNumberHash,
  required String expiryMonth,
  required String expiryYear,
  required String cardholderName,
  String? cvc,
  bool? isDefault,
}) async {
  final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<PaymentCard>(
    request: () => di.post(
      kPaymentCardsUrl,
      data: {
        'brand': brand,
        'last_four': lastFour,
        'card_number_hash': cardNumberHash,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'cardholder_name': cardholderName,
        if (cvc != null && cvc.isNotEmpty) 'cvc': cvc,
        if (isDefault != null) 'is_default': isDefault,
      },
    ),
    parser: (data) => PaymentCard.fromJson(data),
  );
}
