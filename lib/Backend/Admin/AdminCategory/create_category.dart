import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Category/admin_category_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<ApiResponse<AdminCategoryModel>>
createCategory({

  required String code,

  required Map<String, dynamic> name,

  Map<String, dynamic>? description,

  int? displayOrder,

  bool? isActive,

}) async {

  final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminCategoryModel>(

    request: () => di.post(

      kAdminCategoriesUrl,

      data: {

        'code': code,

        'name': name,

        if (description != null)
          'description':
          description,

        if (displayOrder != null)
          'display_order':
          displayOrder,

        if (isActive != null)
          'is_active':
          isActive,
      },
    ),

    parser: (data) =>
        AdminCategoryModel
            .fromJson(data),
  );
}