import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminMachine/admin_machine_create_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminMachineCreateModel
    >
> createAdminMachine({

  required int userId,
  required int addressId,
  required int productId,

  required String serialNumber,
  required String term,

  required String installedAt,

  int? filterChangeIntervalMonths,

  String? locationLabel,
  String? countryCode,
  String? notes,

  bool? isActive,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<
      AdminMachineCreateModel>(

    request: () => di.post(

      kAdminMachinesUrl,

      data: {

        'user_id': userId,
        'address_id': addressId,
        'product_id': productId,

        'serial_number': serialNumber,
        'term': term,

        'installed_at': installedAt,

        if (filterChangeIntervalMonths != null)
          'filter_change_interval_months':
          filterChangeIntervalMonths,

        if (locationLabel != null)
          'location_label': locationLabel,

        if (countryCode != null)
          'country_code': countryCode,

        if (notes != null)
          'notes': notes,

        if (isActive != null)
          'is_active': isActive,
      },
    ),

    parser: (data) =>
        AdminMachineCreateModel
            .fromJson(data),
  );
}