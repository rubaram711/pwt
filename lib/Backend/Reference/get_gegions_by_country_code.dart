import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';
import '../../Models/Reference/region_model.dart';

Future<ApiResponse<List<RegionModel>>>
getRegionsByCountryCode({

  required String countryCode,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<
      List<RegionModel>>(

    request: () => di.get(
      '$kCountriesUrl/$countryCode/regions',
    ),

    parser: (data) =>

        (data as List)

            .map(
              (e) => RegionModel
              .fromJson(e),
        )

            .toList(),
  );
}