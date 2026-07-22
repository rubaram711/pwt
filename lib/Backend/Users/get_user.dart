import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';
import '../../Models/Auth/user_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<User>> getProfile() async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<User>(

    request: () => di.get(
      kProfileUrl,
    ),

    parser: (data) => User.fromJson(data),
  );
}