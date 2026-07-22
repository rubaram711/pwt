import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';
import '../../Models/Auth/register_response_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
//todo check token
Future<ApiResponse<AuthResponse>> register(
    String name,
    String? email,
    String password,
    String passwordConfirmation,
    String locale,
    String accountType, {
    String? companyName,
    }) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<AuthResponse>(

    request: () => di.post(
      kRegisterUrl,
      data: {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
        "locale": locale,
        "account_type": accountType,
        if (companyName != null && companyName.isNotEmpty) "company_name": companyName,
      },
    ),

    parser: (data) => AuthResponse.fromJson(data),
  );
}
