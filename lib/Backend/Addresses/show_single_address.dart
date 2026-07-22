import'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../const/urls.dart';
import '../../Models/address_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<AddressModel>> getAddress(
    int addressId,
    ) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<AddressModel>(

    request: () => di.get(
      "$kAddressesUrl/$addressId",
    ),

    parser: (data) => AddressModel.fromJson(data),
  );
}