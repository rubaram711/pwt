import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';
import '../../Models/Auth/login_otp_response.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<LoginOtpResponse>> requestLoginOtp(
    String phone,
    ) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<LoginOtpResponse>(

    request: () => di.post(
      kLoginOtpUrl,
      data: {
        "phone": phone,
      },
    ),

    parser: (data) => LoginOtpResponse.fromJson(data),
  );
}