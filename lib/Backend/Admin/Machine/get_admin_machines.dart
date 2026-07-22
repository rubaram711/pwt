import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/AdminMachine/admin_machine_model.dart';
import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<
            AdminMachineModel
        >
    >
> getAdminMachines({

  int page = 1,
  int perPage = 15,

  String? search,
  String? countryCode,

  int? productId,
  int? customerId,

  bool? needsMaintenance,
  int? withinDays,

  bool? isActive,

  String? source,
  String? term,

  bool? includeTrashed,

  String? sort,
  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler.handleRequest<
      AdminMachineModel>(

    request: () => di.get(

      kAdminMachinesUrl,

      queryParameters: {

        'page': page,
        'per_page': perPage,

        if (search != null)
          'search': search,

        if (countryCode != null)
          'country_code': countryCode,

        if (productId != null)
          'product_id': productId,

        if (customerId != null)
          'customer_id': customerId,

        if (needsMaintenance != null)
          'needs_maintenance': needsMaintenance,

        if (withinDays != null)
          'within_days': withinDays,

        if (isActive != null)
          'is_active': isActive,

        if (source != null)
          'source': source,

        if (term != null)
          'term': term,

        if (includeTrashed != null)
          'include_trashed': includeTrashed,

        if (sort != null)
          'sort': sort,

        if (order != null)
          'order': order,
      },
    ),

    itemParser: (item) =>
        AdminMachineModel.fromJson(item),
  );
}