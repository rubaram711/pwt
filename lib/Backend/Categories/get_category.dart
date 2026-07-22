import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../../Services/dio_service.dart';
import '../../Models/api_response_model.dart';
import '../../Models/category_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<CategoryModel>>
getCategory(
    int categoryId,
    ) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<CategoryModel>(

    request: () => di.get(
      "$kCategoriesUrl/$categoryId",
    ),

    parser: (data) =>
        CategoryModel.fromJson(data),
  );
}