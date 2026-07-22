import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../Services/dio_service.dart';
import '../../const/urls.dart';
import '../Models/health_model.dart';

Future<ApiResponse<HealthModel>>
getHealthStatus() async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<
      HealthModel>(

    request: () => di.get(
      kHealthUrl,
    ),

    parser: (data) =>
        HealthModel.fromJson(data),
  );
}

//وين ممكن نستخدمو داخل التطبيق؟
//
// غالبًا:
//
// 1. Splash Screen
//
// قبل الدخول للتطبيق:
//
// هل الـ API شغال؟
// إذا لا:
// "Servers are under maintenance"
// 2. Monitoring داخلي
//
// لو عندكن admin dashboard.
//
// 3. Retry Logic
//
// إذا health fail:
//
// نوقف requests
// نظهر offline state