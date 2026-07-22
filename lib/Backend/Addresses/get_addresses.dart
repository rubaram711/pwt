import'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../const/urls.dart';
import '../../Models/address_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<List<AddressModel>>> getAddresses() async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<List<AddressModel>>(

    request: () => di.get(
      kAddressesUrl,
    ),

    parser: (data) =>
        (data as List)
            .map((e) => AddressModel.fromJson(e))
            .toList(),
  );
}