import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../const/urls.dart';
import '../../Models/Reference/country_model.dart';

Future<ApiResponse<List<CountryModel>>>
getCountries() async {

final dio.Dio di = AppState.instance.dioService.dio;


  return ApiHandler.handleRequest<
      List<CountryModel>>(

    request: () => di.get(
      kCountriesUrl,
    ),

    parser: (data) =>

        (data as List)

            .map(
              (e) => CountryModel
              .fromJson(e),
        )

            .toList(),
  );
}