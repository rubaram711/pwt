import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';
import '../../Models/Auth/register_response_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<AuthResponse>> verifyLoginOtp(
    String phone,
    String otp,
    ) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<AuthResponse>(

    request: () => di.post(
      kVerifyLoginOtpUrl,
      data: {
        "phone": phone,
        "otp": otp,
      },
    ),

    parser: (data) => AuthResponse.fromJson(data),
  );
}