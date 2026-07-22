import 'package:dio/dio.dart';

import '../Models/api_response_model.dart';

class ApiHandler {

  static Future<ApiResponse<T>> handleRequest<T>({
    required Future<Response> Function() request,
    required T Function(dynamic data) parser,
  }) async {

    try {

      final response = await request();

      return ApiResponse<T>(
        success: response.data['success'] ?? true,
        message: response.data['message'],
        code: response.data['code'],
        data: response.data['data'] != null
            ? parser(response.data['data'])
            : null,
      );

    } on DioException catch (e) {

      final data = e.response?.data;

      return ApiResponse<T>(
        success: false,
        message: data?['message'],
        error: data?['error'],
        code: data?['code'],
        errors: _parseErrors(data?['errors']),
      );

    } catch (e) {

      return ApiResponse<T>(
        success: false,
        message: e.toString(),
      );
    }
  }

  static Map<String, List<String>>? _parseErrors(dynamic errors) {
    if (errors == null) return null;
    return Map<String, List<String>>.from(
      (errors as Map).map((key, value) {
        final List<String> msgs;
        if (value is List) {
          msgs = List<String>.from(value);
        } else if (value is Map) {
          msgs = value.values.map((v) => v.toString()).toList();
        } else {
          msgs = [value.toString()];
        }
        return MapEntry(key.toString(), msgs);
      }),
    );
  }
}