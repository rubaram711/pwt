import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';
import '../../../const/urls.dart';
import '../../../Models/payment_card_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';

/// Saves a card that has already been tokenized by Stripe (a `pm_xxxxx`
/// PaymentMethod). The backend attaches it to the user's Stripe Customer
/// and returns the display metadata (brand/last4/expiry) — no raw card
/// data is ever sent here.
Future<ApiResponse<PaymentCard>> createPaymentCard({
  required String paymentMethodId,
  bool? isDefault,
}) async {
  final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<PaymentCard>(
    request: () => di.post(
      kPaymentCardsUrl,
      data: {
        'payment_method_id': paymentMethodId,
        if (isDefault != null) 'is_default': isDefault,
      },
    ),
    parser: (data) => PaymentCard.fromJson(data),
  );
}
