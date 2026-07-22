import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';
import '../../Models/api_response_model.dart';
import '../../Models/empty_response.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<EmptyResponse>> resetPassword({
  required String email,
  required String token,
  required String password,
  required String passwordConfirmation,
}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  final result = await ApiHandler.handleRequest<EmptyResponse>(
    request: () => di.post(
      kResetPasswordUrl,
      data: {
        "email": email,
        "token": token,
        "password": password,
        "password_confirmation": passwordConfirmation,
      },
    ),
    parser: (_) => EmptyResponse(),
  );
  print('resetPassword => success: ${result.success}, message: ${result.message}');
  return result;
}