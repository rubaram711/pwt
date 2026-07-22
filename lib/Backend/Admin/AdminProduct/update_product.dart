import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminProduct/admin_product_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<ApiResponse<AdminProductModel>>
updateProduct({

  required int productId,

  required int categoryId,

  required Map<String, dynamic> name,

  Map<String, dynamic>? shortDescription,

  Map<String, dynamic>? description,

  Map<String, dynamic>? benefits,

  bool? isActive,

  bool? isFeatured,

  bool? isQuoteOnly,

  String? stockStatus,

  int? displayOrder,

  List<Map<String, dynamic>>? prices,

  List<Map<String, dynamic>>? specs,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminProductModel>(

    request: () => di.put(

      '$kAdminProductsUrl/$productId',

      data: {

        'category_id':
        categoryId,

        'name': name,

        if (shortDescription != null)
          'short_description':
          shortDescription,

        if (description != null)
          'description':
          description,

        if (benefits != null)
          'benefits':
          benefits,

        if (isActive != null)
          'is_active':
          isActive,

        if (isFeatured != null)
          'is_featured':
          isFeatured,

        if (isQuoteOnly != null)
          'is_quote_only':
          isQuoteOnly,

        if (stockStatus != null)
          'stock_status':
          stockStatus,

        if (displayOrder != null)
          'display_order':
          displayOrder,

        if (prices != null)
          'prices': prices,

        if (specs != null)
          'specs': specs,
      },
    ),

    parser: (data) =>
        AdminProductModel
            .fromJson(data),
  );
}