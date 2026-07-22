import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../../Services/dio_service.dart';
import '../../Models/Promotion/promotion_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<List<PromotionModel>>>
getPromotions() async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<List<PromotionModel>>(

    request: () => di.get(
      kPromotionsUrl,
    ),

    parser: (data) =>

        (data as List)

            .map(
              (e) =>
              PromotionModel
                  .fromJson(e),
        )

            .toList(),
  );
}