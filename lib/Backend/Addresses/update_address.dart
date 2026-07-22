import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../../const/urls.dart';
import '../../Models/address_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<AddressModel>> updateAddress({

  required int addressId,

  String? label,
  String? recipientName,
  String? recipientPhone,
  String? line1,
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

    request: () => di.patch(

      "$kAddressesUrl/$addressId",

      data: {

        if (label != null)
          "label": label,

        if (recipientName != null)
          "recipient_name": recipientName,

        if (recipientPhone != null)
          "recipient_phone": recipientPhone,

        if (line1 != null)
          "line1": line1,

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