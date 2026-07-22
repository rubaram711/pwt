import 'package:dio/dio.dart' as dio;
import '../../Models/Products/products_model.dart';
import '../../myWeb2/state/app_state.dart';
import '../../Services/paginated_api_handler.dart';
import '../../Models/Pagination/paginated_response_model.dart';
import '../../Models/api_response_model.dart';
import '../../const/urls.dart';

Future<ApiResponse<PaginatedResponse<ProductModel>>> getFilteredProducts({
  String? tagLabel,
  int page = 1,
  int perPage = 15,
}) async {

  final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler.handleRequest<ProductModel>(

    request: () => di.get(
      kProductsUrl,
      queryParameters: {
        "page": page,
        "per_page": perPage,
        if (tagLabel != null) "tag_label": tagLabel,
      },
    ),

    itemParser: (item) => ProductModel.fromJson(item),
  );
}
