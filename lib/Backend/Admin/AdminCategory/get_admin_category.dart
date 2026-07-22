import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';


import '../../../Models/AdminModels/Category/admin_category_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<ApiResponse<AdminCategoryModel>>
getAdminCategory({

  required int categoryId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminCategoryModel>(

    request: () => di.get(
      '$kAdminCategoriesUrl/$categoryId',
    ),

    parser: (data) =>
        AdminCategoryModel
            .fromJson(data),
  );
}