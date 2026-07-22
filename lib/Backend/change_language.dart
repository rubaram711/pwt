import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Services/dio_service.dart';
import '../../const/urls.dart';
import '../Models/api_response_model.dart';

Future<ApiResponse<bool>> changeLanguage(
    String language,
    ) async {
final dio.Dio di = AppState.instance.dioService.dio;

  try {
    final response = await di.post(
      kChangeLanguageUrl,
      data: {
        "language": language,
      },
    );

    return ApiResponse(
      success: true,
      message: response.data['message'],
      data: true,
    );
  } on dio.DioException catch (e) {
    final data = e.response?.data;

    return ApiResponse(
      success: false,
      message: data?['message'],
      error: data?['error'],
      errors: data?['errors'] != null
          ? Map<String, List<String>>.from(
        (data!['errors'] as Map).map(
              (key, value) => MapEntry(
            key.toString(),
            List<String>.from(value),
          ),
        ),
      )
          : null,
    );
  }
}