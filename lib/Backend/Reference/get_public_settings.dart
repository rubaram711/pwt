import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';
import '../../Models/Reference/public_settings_model.dart';

Future<ApiResponse<PublicSettingsModel>>
getPublicSettings() async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<
      PublicSettingsModel>(

    request: () => di.get(
      kPublicSettingsUrl,
    ),

    parser: (data) =>
        PublicSettingsModel
            .fromJson(data),
  );
}