import 'package:dio/dio.dart' as dio;
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../const/urls.dart';
import '../../Models/Reference/city_model.dart';
import '../../myWeb2/state/app_state.dart';

Future<ApiResponse<List<CityModel>>> getCitiesForCountry(String countryCode) async {
  final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<List<CityModel>>(
    request: () => di.get('$kCountriesUrl/${countryCode.toLowerCase()}/cities'),
    parser: (data) =>
        (data as List).map((e) => CityModel.fromJson(e)).toList(),
  );
}
