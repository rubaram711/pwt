import 'package:dio/dio.dart' as dio;
import '../../../const/urls.dart';
import '../../Models/address_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../myWeb2/state/app_state.dart';


Future<ApiResponse<AddressModel>> createAddress({

  required String label,
  required String line1,
  String? recipientName,
  String? recipientPhone,

  String? line2,
  String? city,
  String? postalCode,
  int? countryId,
  int? regionId,
  bool? isDefault,
  String? notes,

}) async {

  final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<AddressModel>(

    request: () => di.post(
      kAddressesUrl,

      data: {

        "label": label,
        "line1": line1,
        if (recipientName != null) "recipient_name": recipientName,
        if (recipientPhone != null) "recipient_phone": recipientPhone,

        if (line2 != null)
          "line2": line2,

        if (city != null)
          "city": city,

        if (postalCode != null)
          "postal_code": postalCode,

        if (countryId != null)
          "country_id": countryId,

        if (regionId != null)
          "region_id": regionId,

        if (isDefault != null)
          "is_default": isDefault,

        if (notes != null)
          "notes": notes,
      },
    ),

    parser: (data) => AddressModel.fromJson(data),
  );
}