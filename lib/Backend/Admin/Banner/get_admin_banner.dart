import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Banner/admin_banner_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminBannerModel
    >
> getAdminBanner({

  required int bannerId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<
      AdminBannerModel>(

    request: () => di.get(

      '$kAdminBannersUrl/$bannerId',
    ),

    parser: (data) =>
        AdminBannerModel
            .fromJson(data),
  );
}