import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminProduct/admin_product_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';


Future<ApiResponse<AdminProductModel>>
attachProductImage({

  required int productId,

  required int fileId,

  Map<String, dynamic>? altText,

  bool? isPrimary,

  int? displayOrder,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminProductModel>(

    request: () => di.post(

      '$kAdminProductsUrl/$productId/images',

      data: {

        'file_id': fileId,

        if (altText != null)
          'alt_text': altText,

        if (isPrimary != null)
          'is_primary':
          isPrimary,

        if (displayOrder != null)
          'display_order':
          displayOrder,
      },
    ),

    parser: (data) =>
        AdminProductModel
            .fromJson(data),
  );
}