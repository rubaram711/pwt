import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Banner/admin_banner_delete_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminBannerDeleteModel
    >
> deleteAdminBanner({

  required int bannerId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminBannerDeleteModel

  >(

    request: () => di.delete(

      '$kAdminBannersUrl/$bannerId',
    ),

    parser: (data) =>
        AdminBannerDeleteModel
            .fromJson(data),
  );
}