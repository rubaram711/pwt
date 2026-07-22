import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Promotions/admin_promotion_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminPromotionModel
    >
> getAdminPromotion({

  required int promotionId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<
      AdminPromotionModel>(

    request: () => di.get(

      '$kAdminPromotionsUrl/$promotionId',
    ),

    parser: (data) =>
        AdminPromotionModel
            .fromJson(data),
  );
}