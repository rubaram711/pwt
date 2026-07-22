import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';
import '../../Models/Auth/register_response_model.dart';
import '../../Models/Auth/token_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<TokenModel>> verifyRegisterOtp(
    String phone,
    String otp,
    String accountType,
    ) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<TokenModel>(

    request: () => di.post(
      kVerifyRegisterOtpUrl,
      data: {
        "phone": phone,
        "otp": otp,
        "account_type": accountType,
      },
    ),

    parser: (data) => TokenModel.fromJson(data),
  );
}