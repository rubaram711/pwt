import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../../Services/dio_service.dart';
import '../../Models/api_response_model.dart';
import '../../Models/banner_model.dart';
import '../../const/urls.dart';
import '../Services/api_handler.dart';

Future<ApiResponse<List<BannerModel>>>
getBanners({

  String? placement,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<List<BannerModel>>(

    request: () => di.get(

      kBannersUrl,

      queryParameters: {

        if(placement != null)
          "placement": placement,
      },
    ),

    parser: (data) =>

        (data as List)

            .map(
              (e) =>
              BannerModel.fromJson(e),
        )

            .toList(),
  );
}