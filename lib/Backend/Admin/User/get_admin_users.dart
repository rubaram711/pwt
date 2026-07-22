import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/UserModels/admin_user_list_item_model.dart';
import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<
            AdminUserListItemModel
        >
    >
> getAdminUsers({

  int page = 1,

  int perPage = 15,

  String? search,

  String? role,

  bool? isActive,

  bool? includeTrashed,

  String? createdFrom,

  String? createdTo,

  String sort = 'created_at',

  String order = 'desc',

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<
      AdminUserListItemModel>(

    request: () => di.get(

      kAdminUsersUrl,

      queryParameters: {

        'page': page,

        'per_page': perPage,

        if (search != null)
          'search': search,

        if (role != null)
          'role': role,

        if (isActive != null)
          'is_active': isActive,

        if (includeTrashed != null)
          'include_trashed':
          includeTrashed,

        if (createdFrom != null)
          'created_from':
          createdFrom,

        if (createdTo != null)
          'created_to':
          createdTo,

        'sort': sort,

        'order': order,
      },
    ),

    itemParser: (item) =>
        AdminUserListItemModel
            .fromJson(item),
  );
}