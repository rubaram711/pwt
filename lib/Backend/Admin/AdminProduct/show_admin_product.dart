import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminProduct/admin_product_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<ApiResponse<AdminProductModel>>
getAdminProduct({

  required int productId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminProductModel>(

    request: () => di.get(
      '$kAdminProductsUrl/$productId',
    ),

    parser: (data) =>
        AdminProductModel
            .fromJson(data),
  );
}