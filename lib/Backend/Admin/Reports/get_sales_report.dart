import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Reports/SalesReport/sales_report_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<SalesReportModel>
> getSalesReport({

  String? dateFrom,

  String? dateTo,

  int? productId,

  String? country,

  String? term,

  String? paymentMethod,

  String? bucket,

  int page = 1,

  int perPage = 25,

  String? sort,

  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  try {

    final response = await di.get(

      kAdminReportsSalesUrl,

      queryParameters: {

        if (dateFrom != null)
          'date_from': dateFrom,

        if (dateTo != null)
          'date_to': dateTo,

        if (productId != null)
          'product_id': productId,

        if (country != null)
          'country': country,

        if (term != null)
          'term': term,

        if (paymentMethod != null)
          'payment_method':
          paymentMethod,

        if (bucket != null)
          'bucket': bucket,

        'page': page,

        'per_page': perPage,

        if (sort != null)
          'sort': sort,

        if (order != null)
          'order': order,
      },
    );

    return ApiResponse<SalesReportModel>(

      success:
      response.data['success'],

      message:
      response.data['message'],

      code:
      response.data['code'],

      data:
      SalesReportModel.fromJson(

        response.data['data'],

        response.data['meta'],
      ),
    );

  } on dio.DioException catch (e) {

    final data = e.response?.data;

    return ApiResponse<SalesReportModel>(

      success: false,

      message: data?['message'],

      error: data?['error'],

      code: data?['code'],
    );
  }
}