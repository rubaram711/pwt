import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminProduct/remove_product_image_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        RemoveProductImageResponseModel
    >
> detachProductImage({

  required int productId,

  required int imageId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      RemoveProductImageResponseModel>(

    request: () => di.delete(
      '$kAdminProductsUrl/$productId/images/$imageId',
    ),

    parser: (data) =>
        RemoveProductImageResponseModel
            .fromJson(data),
  );
}