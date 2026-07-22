import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../../Services/dio_service.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../Models/empty_response.dart';
import '../../const/urls.dart';

Future<ApiResponse<EmptyResponse>> deleteFile(int id) async {
final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<EmptyResponse>(
    request: () => di.delete(
      '$kFilesUrl/$id',
    ),
    parser: (data) => EmptyResponse.fromJson(data),
  );
}