import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Reports/CustomersReport/customers_report_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        CustomersReportModel
    >
> getCustomersReport({

  String? dateFrom,

  String? dateTo,

  String? country,

  bool? hasOrders,

  bool? isActive,

  int page = 1,

  int perPage = 25,

  String? sort,

  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  try {

    final response = await di.get(

      kAdminReportsCustomersUrl,

      queryParameters: {

        if (dateFrom != null)
          'date_from': dateFrom,

        if (dateTo != null)
          'date_to': dateTo,

        if (country != null)
          'country': country,

        if (hasOrders != null)
          'has_orders': hasOrders,

        if (isActive != null)
          'is_active': isActive,

        'page': page,

        'per_page': perPage,

        if (sort != null)
          'sort': sort,

        if (order != null)
          'order': order,
      },
    );

    return ApiResponse<
        CustomersReportModel>(

      success:
      response.data['success'],

      message:
      response.data['message'],

      code:
      response.data['code'],

      data:
      CustomersReportModel
          .fromJson(

        response.data['data'],

        response.data['meta'],
      ),
    );

  } on dio.DioException catch (e) {

    final data = e.response?.data;

    return ApiResponse<
        CustomersReportModel>(

      success: false,

      message: data?['message'],

      error: data?['error'],

      code: data?['code'],
    );
  }
}