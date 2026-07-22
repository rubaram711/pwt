import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../const/urls.dart';
import '../../Models/Auth/register_response_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<AuthResponse>> login(
    String email,
    String password,
    String accountType,
    ) async {

final dio.Dio di = AppState.instance.dioService.dio;

  final result = await ApiHandler.handleRequest<AuthResponse>(
    request: () => di.post(
      kLoginUrl,
      data: {
        "email": email,
        "password": password,
        "account_type": accountType,
      },
    ),
    parser: (data) => AuthResponse.fromJson(data),
  );
  print('login => success: ${result.success}, message: ${result.message}, userId: ${result.data?.user.id}, name: ${result.data?.user.name}, accountType: ${result.data?.user.accountType}');
  return result;
}
