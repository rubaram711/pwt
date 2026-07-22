import 'package:dio/dio.dart' as dio;
import '../../Models/Products/products_model.dart';
import '../../myWeb2/state/app_state.dart';
import '../../const/urls.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<ProductModel>>
getProductDetails(int id) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<ProductModel>(

    request: () => di.get(
      "$kProductsUrl/$id",
    ),

    parser: (data) =>
        ProductModel.fromJson(
          data,
        ),
  );
}