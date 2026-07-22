import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../../const/urls.dart';
import '../../Models/Auth/verify_reset_otp_response.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<VerifyResetOtpResponse>> verifyResetOtp({
  required String email,
  required String otp,
}) async {
  final dio.Dio di = AppState.instance.dioService.dio;

  final result = await ApiHandler.handleRequest<VerifyResetOtpResponse>(
    request: () => di.post(
      kVerifyResetOtpUrl,
      data: {
        "email": email,
        "otp": otp,
      },
    ),
    parser: (data) => VerifyResetOtpResponse.fromJson(data),
  );
  print('verifyResetOtp => success: ${result.success}, message: ${result.message}, devToken: ${result.data?.devToken}, expiresAt: ${result.data?.expiresAt}');
  return result;
}
