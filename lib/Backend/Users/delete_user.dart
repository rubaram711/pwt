import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';
import '../../Models/api_response_model.dart';
import '../../Models/empty_response.dart';
import '../../Services/api_handler.dart';


Future<ApiResponse<EmptyResponse>> deleteAccount({
  required String currentPassword,
  required String confirm,
}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<EmptyResponse>(

    request: () => di.delete(
      kProfileUrl,
      data: {
        "current_password": currentPassword,
        "confirm": confirm,
      },
    ),

    parser: (_) => EmptyResponse(),
  );
}