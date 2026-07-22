import 'package:dio/dio.dart' as dio;
import '../myWeb2/state/app_state.dart';
import '../Models/api_response_model.dart';
import '../Models/contact_model.dart';
import '../Services/api_handler.dart';
import '../const/urls.dart';

Future<ApiResponse<ContactModel>>
submitContactForm({

  required String name,
  required String email,
  required String phone,
  required String subject,
  required String message,

  String source = 'web',
  String type = 'general',

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<ContactModel>(

    request: () => di.post(

      kContactUrl,

      data: {

        'name': name,

        'email': email,

        'phone': phone,

        'subject': subject,

        'message': message,

        'source': source,

        'type': type,
      },
    ),

    parser: (data) =>
        ContactModel.fromJson(data),
  );
}