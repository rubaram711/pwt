import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/OrderModel/admin_order_model.dart';
import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<AdminOrderModel>
    >
> getAdminOrders({

  int page = 1,

  int perPage = 15,

  String? status,

  String? search,

  String? dateFrom,

  String? dateTo,

  String? paymentMethod,

  String? country,

  bool? includeTrashed,

  String? sort,

  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<AdminOrderModel>(

    request: () => di.get(

      kAdminOrdersUrl,

      queryParameters: {

        'page': page,

        'per_page': perPage,

        if (status != null)
          'status': status,

        if (search != null)
          'search': search,

        if (dateFrom != null)
          'date_from': dateFrom,

        if (dateTo != null)
          'date_to': dateTo,

        if (paymentMethod != null)
          'payment_method':
          paymentMethod,

        if (country != null)
          'country': country,

        if (includeTrashed != null)
          'include_trashed':
          includeTrashed,

        if (sort != null)
          'sort': sort,

        if (order != null)
          'order': order,
      },
    ),

    itemParser: (item) =>
        AdminOrderModel.fromJson(item),
  );
}