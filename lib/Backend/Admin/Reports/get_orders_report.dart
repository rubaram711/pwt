import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Reports/OrdersReport/orders_report_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<OrdersReportModel>
> getOrdersReport({

  String? dateFrom,

  String? dateTo,

  String? status,

  String? country,

  String? paymentMethod,

  String? term,

  int page = 1,

  int perPage = 25,

  String? sort,

  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  try {

    final response = await di.get(

      kAdminReportsOrdersUrl,

      queryParameters: {

        if (dateFrom != null)
          'date_from': dateFrom,

        if (dateTo != null)
          'date_to': dateTo,

        if (status != null)
          'status': status,

        if (country != null)
          'country': country,

        if (paymentMethod != null)
          'payment_method':
          paymentMethod,

        if (term != null)
          'term': term,

        'page': page,

        'per_page': perPage,

        if (sort != null)
          'sort': sort,

        if (order != null)
          'order': order,
      },
    );

    return ApiResponse<OrdersReportModel>(

      success:
      response.data['success'],

      message:
      response.data['message'],

      code:
      response.data['code'],

      data:
      OrdersReportModel.fromJson(

        response.data['data'],

        response.data['meta'],
      ),
    );

  } on dio.DioException catch (e) {

    final data = e.response?.data;

    return ApiResponse<OrdersReportModel>(

      success: false,

      message: data?['message'],

      error: data?['error'],

      code: data?['code'],
    );
  }
}