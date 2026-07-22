import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../../Services/dio_service.dart';
import '../../const/urls.dart';

Future<dio.Response> downloadFile(String uuid) async {
final dio.Dio di = AppState.instance.dioService.dio;

  final response = await di.get(
    '$kFilesUrl/$uuid/download',
    options: dio.Options(
      responseType: dio.ResponseType.bytes,
    ),
  );

  return response;//todo check response
}