import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';


import '../../../Models/AdminModels/Category/delete_category_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        DeleteCategoryResponseModel
    >
> deleteCategory({

  required int categoryId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      DeleteCategoryResponseModel>(

    request: () => di.delete(
      '$kAdminCategoriesUrl/$categoryId',
    ),

    parser: (data) =>
        DeleteCategoryResponseModel
            .fromJson(data),
  );
}