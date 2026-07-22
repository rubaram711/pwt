import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Reports/report_export_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<ReportExportModel>
> exportAdminReport({

  required String type,

  required String format,

  String? dateFrom,

  String? dateTo,

  String? country,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  try {

    final response = await di.get(

      '$kAdminReportsExportUrl/$type/export',

      queryParameters: {

        'format': format,

        if (dateFrom != null)
          'date_from': dateFrom,

        if (dateTo != null)
          'date_to': dateTo,

        if (country != null)
          'country': country,
      },

      options: dio.Options(
        responseType:
        dio.ResponseType.bytes,
      ),
    );

    return ApiResponse<
        ReportExportModel>(

      success: true,

      data: ReportExportModel(

        bytes:
        response.data,

        contentType:
        response.headers.value(
          'content-type',
        ),

        fileName:
        response.headers.value(
          'content-disposition',
        ),

        isTruncated:

        response.headers.value(
          'x-pwt-export-truncated',
        ) == 'true',

        rowCount:
        response.headers.value(
          'x-pwt-export-row-count',
        ),
      ),
    );

  } on dio.DioException catch (e) {

    final data = e.response?.data;

    return ApiResponse<
        ReportExportModel>(

      success: false,

      message: data?['message'],

      error: data?['error'],

      code: data?['code'],
    );
  }
}