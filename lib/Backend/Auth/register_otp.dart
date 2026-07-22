import '../../myWeb2/state/app_state.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';
import '../../Models/Auth/login_otp_response.dart';
import '../../Models/Auth/register_response_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import 'package:dio/dio.dart' as dio;

Future<ApiResponse<LoginOtpResponse>> requestRegisterOtp(
    String phone,
    String accountType,
    ) async {

final dio.Dio di = AppState.instance.dioService.dio;

  final result = await ApiHandler.handleRequest<LoginOtpResponse>(
    request: () => di.post(
      kRegisterOtpUrl,
      data: {
        "phone": phone,
        "account_type": accountType,
      },
    ),
    parser: (data) => LoginOtpResponse.fromJson(data),
  );
  print('requestRegisterOtp => success: ${result.success}, message: ${result.message}, otpId: ${result.data?.otpId}, expiresAt: ${result.data?.expiresAt}, devOtp: ${result.data?.devOtp}');
  return result;
}