import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Promotions/admin_promotion_delete_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminPromotionDeleteModel
    >
> deleteAdminPromotion({

  required int promotionId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminPromotionDeleteModel

  >(

    request: () => di.delete(

      '$kAdminPromotionsUrl/$promotionId',
    ),

    parser: (data) =>
        AdminPromotionDeleteModel
            .fromJson(data),
  );
}