import 'package:dio/dio.dart';
import 'package:pwt_website/Models/Pagination/paginated_response_model.dart';
import 'package:pwt_website/Models/Pagination/pagination_model.dart';
import '../Models/api_response_model.dart';

class PaginatedApiHandler {

  static Future<
      ApiResponse<PaginatedResponse<T>>
  > handleRequest<T>({

    required Future<Response> Function()
    request,

    required T Function(dynamic item)
    itemParser,

  }) async {

    try {

      final response = await request();

      final responseData =
      response.data['data'];

      final meta =
      response.data['meta'];

      return ApiResponse<
          PaginatedResponse<T>
      >(

        success:
        response.data['success'] ?? true,

        message:
        response.data['message'],

        code:
        response.data['code'],

        data: PaginatedResponse<T>(

          items:

          (responseData as List)

              .map(
                (e) => itemParser(e),
          )

              .toList(),

          pagination:

          meta != null &&
              meta['pagination'] != null

              ? PaginationModel.fromJson(
            meta['pagination'],
          )

              : null,

          meta: meta,
        ),
      );

    } on DioException catch (e) {

      final data = e.response?.data;

      return ApiResponse<
          PaginatedResponse<T>
      >(

        success: false,

        message: data?['message'],

        error: data?['error'],

        code: data?['code'],

        errors: _parseErrors(
          data?['errors'],
        ),
      );

    } catch (e) {

      return ApiResponse<
          PaginatedResponse<T>
      >(

        success: false,

        message: e.toString(),
      );
    }
  }

  static Map<String, List<String>>?
  _parseErrors(dynamic errors) {

    if (errors == null) return null;

    return Map<String, List<String>>.from(

      (errors as Map).map(

            (key, value) => MapEntry(

          key.toString(),

          List<String>.from(value),
        ),
      ),
    );
  }
}