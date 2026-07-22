import 'dart:io';
import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../../Services/dio_service.dart';
import '../../Models/api_response_model.dart';
import '../../Models/file_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<FileModel>> uploadFile({
  required File file,
  required String type,
}) async {
final dio.Dio di = AppState.instance.dioService.dio;

  final formData = dio.FormData.fromMap({
    'file': await dio.MultipartFile.fromFile(file.path),
    'type': type,
  });

  return ApiHandler.handleRequest<FileModel>(
    request: () => di.post(
      kFilesUrl,
      data: formData,
    ),
    parser: (data) => FileModel.fromJson(data),
  );
}