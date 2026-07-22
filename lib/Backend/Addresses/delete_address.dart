import 'package:dio/dio.dart' as dio;
import '../../../const/urls.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../myWeb2/state/app_state.dart';

Future<ApiResponse<DeleteAddressResponse>> deleteAddress(
    int addressId,
    ) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<DeleteAddressResponse>(

    request: () => di.delete(
      "$kAddressesUrl/$addressId",
    ),

    parser: (data) =>
        DeleteAddressResponse.fromJson(data),
  );
}


class DeleteAddressResponse {

  final int? id;
  final int? promotedDefaultId;

  DeleteAddressResponse({
    this.id,
    this.promotedDefaultId,
  });

  factory DeleteAddressResponse.fromJson(
      Map<String, dynamic> json,
      ) {

    return DeleteAddressResponse(
      id: json['id'],
      promotedDefaultId: json['promoted_default_id'],
    );
  }
}
