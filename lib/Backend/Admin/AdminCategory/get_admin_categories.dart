import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';


import '../../../Models/AdminModels/Category/admin_category_model.dart';
import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<
            AdminCategoryModel
        >
    >
> getAdminCategories({

  int page = 1,

  int perPage = 15,

  String? search,

  bool? isActive,

  int? parentId,

  bool? includeTrashed,

  String sort = 'display_order',

  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<
      AdminCategoryModel>(

    request: () => di.get(

      kAdminCategoriesUrl,

      queryParameters: {

        'page': page,

        'per_page': perPage,

        if (search != null)
          'search': search,

        if (isActive != null)
          'is_active': isActive,

        if (parentId != null)
          'parent_id': parentId,

        if (includeTrashed != null)
          'include_trashed':
          includeTrashed,

        'sort': sort,

        if (order != null)
          'order': order,
      },
    ),

    itemParser: (item) =>
        AdminCategoryModel
            .fromJson(item),
  );
}