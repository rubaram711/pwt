import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import '../../../const/urls.dart';
import '../../Models/Auth/user_model.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<User>> addUpdatePhotoAuthenticated({
  required Uint8List bytes,
  required String filename,
}) async {
  final dio.Dio di = AppState.instance.dioService.dio;

  final formData = dio.FormData.fromMap({
    'avatar': dio.MultipartFile.fromBytes(bytes, filename: filename),
  });

  return ApiHandler.handleRequest<User>(
    request: () => di.post(
      kAvatarUrl,
      data: formData,
    ),
    parser: (data) => User.fromJson(data),
  );
}
