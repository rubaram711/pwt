import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/UserModels/admin_user_list_item_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<ApiResponse<AdminUserListItemModel>>
getAdminUser({

  required int userId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      AdminUserListItemModel>(

    request: () => di.get(
      '$kAdminUsersUrl/$userId',
    ),

    parser: (data) =>
        AdminUserListItemModel
            .fromJson(data),
  );
}