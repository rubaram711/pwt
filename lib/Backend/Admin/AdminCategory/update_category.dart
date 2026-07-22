import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';


import '../../../Models/AdminModels/Category/admin_category_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../const/urls.dart';

Future<ApiResponse<AdminCategoryModel>>
updateCategory({

  required int categoryId,

  required String code,

  required Map<String, dynamic> name,

  Map<String, dynamic>? description,

  required bool isActive,

  required int displayOrder,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminCategoryModel>(

    request: () => di.put(

      '$kAdminCategoriesUrl/$categoryId',

      data: {

        'code': code,

        'name': name,

        'description': description,

        'is_active': isActive,

        'display_order':
        displayOrder,
      },
    ),

    parser: (data) =>
        AdminCategoryModel
            .fromJson(data),
  );
}