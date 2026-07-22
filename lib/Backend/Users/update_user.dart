import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import 'package:pwt_website/Models/Auth/user_model.dart';

import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';

Future<ApiResponse<User>> updateProfile({
  String? name,
  String? email,
  String? phone,
  String? phoneCountryCode,
  String? companyName,
  String? currentPassword,
  String? locale,
}) async {

  final dio.Dio di = AppState.instance.dioService.dio;

  final body = {
    if (name != null) "name": name,
    if (email != null) "email": email,
    if (phone != null && phone.isNotEmpty) "phone": phone,
    if (phone != null && phone.isNotEmpty && phoneCountryCode != null) "phone_country_code": phoneCountryCode,
    if (companyName != null) "company_name": companyName,
    if (currentPassword != null) "current_password": currentPassword,
    if (locale != null) "locale": locale,
  };

  print('[updateProfile] sending body: $body');
  print('[updateProfile] currentPassword provided: ${currentPassword != null} (value: "$currentPassword")');

  final result = await ApiHandler.handleRequest<User>(
    request: () => di.patch(kProfileUrl, data: body),
    parser: (data) {
      print('[updateProfile] raw response data: $data');
      final user = User.fromJson(data);
      print('[updateProfile] parsed user => name: ${user.name}, email: ${user.email}, companyName: ${user.companyName}');
      return user;
    },
  );

  print('[updateProfile] success: ${result.success}, message: ${result.message}');
  return result;
}