import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminProduct/update_product_status_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';


Future<
    ApiResponse<
        UpdateProductStatusModel
    >
> updateProductStatus({

  required int productId,

  bool? isActive,

  bool? isFeatured,

  bool? isQuoteOnly,

  String? stockStatus,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      UpdateProductStatusModel>(

    request: () => di.patch(

      '$kAdminProductsUrl/$productId/status',

      data: {

        if (isActive != null)
          'is_active': isActive,

        if (isFeatured != null)
          'is_featured':
          isFeatured,

        if (isQuoteOnly != null)
          'is_quote_only':
          isQuoteOnly,

        if (stockStatus != null)
          'stock_status':
          stockStatus,
      },
    ),

    parser: (data) =>
        UpdateProductStatusModel
            .fromJson(data),
  );
}