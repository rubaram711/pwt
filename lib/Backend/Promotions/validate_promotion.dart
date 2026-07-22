import '../../myWeb2/state/app_state.dart';
import '../../Models/Promotion/validate_promotion_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<ValidatePromotionModel>> validatePromotion({
  required String code,
  required double subtotal,
  required String currency,
  List<int> productIds = const [],
  List<int> categoryIds = const [],
}) async {
  return ApiHandler.handleRequest<ValidatePromotionModel>(
    request: () => AppState.instance.dioService.dio.post(
      kValidatePromotionUrl,
      data: {
        'code': code,
        'subtotal': subtotal,
        'currency': currency,
        'product_ids': productIds,
        'category_ids': categoryIds,
      },
    ),
    parser: (data) => ValidatePromotionModel.fromJson(data),
  );
}