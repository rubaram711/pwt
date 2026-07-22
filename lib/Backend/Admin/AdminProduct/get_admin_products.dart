import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminProduct/admin_product_model.dart';
import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<
            AdminProductModel
        >
    >
> getAdminProducts({

  int page = 1,

  int perPage = 15,

  String? search,

  int? categoryId,

  bool? isActive,

  bool? isFeatured,

  bool? isQuoteOnly,

  String? stockStatus,

  String? term,

  String? createdFrom,

  String? createdTo,

  bool? includeTrashed,

  String sort = 'created_at',

  String order = 'desc',

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<
      AdminProductModel>(

    request: () => di.get(

      kAdminProductsUrl,

      queryParameters: {

        'page': page,

        'per_page': perPage,

        if (search != null)
          'search': search,

        if (categoryId != null)
          'category_id': categoryId,

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

        if (term != null)
          'term': term,

        if (createdFrom != null)
          'created_from':
          createdFrom,

        if (createdTo != null)
          'created_to':
          createdTo,

        if (includeTrashed != null)
          'include_trashed':
          includeTrashed,

        'sort': sort,

        'order': order,
      },
    ),

    itemParser: (item) =>
        AdminProductModel
            .fromJson(item),
  );
}