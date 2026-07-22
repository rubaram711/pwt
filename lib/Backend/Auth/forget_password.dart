import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../../const/urls.dart';
import '../../Models/api_response_model.dart';
import '../../Models/empty_response.dart';
import '../../Services/api_handler.dart';


Future<ApiResponse<EmptyResponse>> forgotPassword(
    String email,
    ) async {

final dio.Dio di = AppState.instance.dioService.dio;

  final result = await ApiHandler.handleRequest<EmptyResponse>(
    request: () => di.post(
      kForgotPasswordUrl,
      data: {
        "email": email,
      },
    ),
    parser: (data) {
      print('forgotPassword data => channel: ${data['channel']}, expiresAt: ${data['expires_at']}, devOtp: ${data['dev_otp']}');
      return EmptyResponse();
    },
  );
  print('forgotPassword => success: ${result.success}, message: ${result.message}');
  return result;
}