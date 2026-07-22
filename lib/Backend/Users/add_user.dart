
// import 'package:dio/dio.dart' as dio;
// import '../../myWeb2/state/app_state.dart';
//
// import '../../../Services/dio_service.dart';
// import '../../../const/urls.dart';
//
// Future addUser(
//     String name,
//     String email,
//     String password,
//     String passwordConfirmation,
//     String active,
//     String posTerminalId,
//     // List<RoleModel> selectedRoles,
//     String isSalesperson,
//     int? cashingMethodId,
//     int? commissionMethodId,
//     String? commission
//     ) async {
// final dio.Dio di = AppState.instance.dioService.dio;
//
//   final dio.FormData formData = dio.FormData.fromMap({
//     "name": name,
//     "email": email,
//     "password": password,
//     "password_confirmation": passwordConfirmation,
//     "is_active": active,
//     "posTerminalId": posTerminalId,
//     "is_salesperson": isSalesperson,
//     'cashing_method_id':cashingMethodId,
//     'commission_method_id':commissionMethodId,
//     'commission':commission,
//   });
//
//   // for (int i = 0; i < selectedRoles.length; i++) {
//   //   formData.fields.add(
//   //     MapEntry("roles[$i]", selectedRoles[i].id.toString()),
//   //   );
//   // }
//
//   try {
//     final dio.Response response = await di.post(
//       kProfileUrl,
//       data: formData,
//     );
//
//     return Map<String, dynamic>.from(response.data);
//   } on dio.DioException catch (e) {
//     return Map<String, dynamic>.from(
//       e.response?.data ??
//           {
//             'success': false,
//             'message': 'Something went wrong',
//           },
//     );
//   }
// }
