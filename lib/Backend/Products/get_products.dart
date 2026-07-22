import 'package:dio/dio.dart' as dio;
import '../../Models/Products/products_model.dart';
import '../../myWeb2/state/app_state.dart';
import '../../Services/paginated_api_handler.dart';
import '../../Models/Pagination/paginated_response_model.dart';
import '../../Models/api_response_model.dart';
import '../../const/urls.dart';

Future<ApiResponse<
    PaginatedResponse<ProductModel>
>> getProducts({

  int page = 1,
  int perPage = 15,

  int? categoryId,

  String? term,

  String? search,

  double? minPrice,

  double? maxPrice,

  String? currency,

  String? sort,

  String? order,

  bool? featured,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<ProductModel>(

    request: () => di.get(

      kProductsUrl,

      queryParameters: {

        "page": page,

        "per_page": perPage,

        if(categoryId != null)
          "category_id": categoryId,

        if(term != null)
          "term": term,

        if(search != null)
          "search": search,

        if(minPrice != null)
          "min_price": minPrice,

        if(maxPrice != null)
          "max_price": maxPrice,

        if(currency != null)
          "currency": currency,

        if(sort != null)
          "sort": sort,

        if(order != null)
          "order": order,

        if(featured != null)
          "featured": featured,
      },
    ),

    itemParser: (item) =>
        ProductModel.fromJson(item),
  );
}