import 'package:dio/dio.dart';
import 'package:pwt_website/const/urls.dart';
import '../myWeb2/state/app_state.dart';

class DioService {
  late final Dio dio;

  DioService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': AppState.instance.lang,
        },
      ),
    );

    _addInterceptors();
  }

  void _addInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AppState.instance.accessToken;

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          options.headers['Accept-Language'] = AppState.instance.lang;

          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            AppState.instance.signOut();
          }
          handler.next(error);
        },
      ),
    );
  }
}
// class DioService {
//   late final Dio dio;
//
//   DioService() {
//     LanguagesController languagesController=Get.find();
//     dio = Dio(
//       BaseOptions(
//         baseUrl: baseUrl,
//         connectTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//         headers: {
//           'Accept': 'application/json',
//           'Accept-Language': languagesController.language
//         },
//       ),
//     );
//
//     _addInterceptors();
//   }
//
//   void _addInterceptors() {
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           final token = Get.find<AuthController>().token.value;
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }
//           handler.next(options);
//         },
//         onError: (error, handler) {
//           if (error.response?.statusCode == 401) {
//             Get.find<AuthController>().logoutUser();
//           }
//           handler.next(error);
//         },
//       ),
//     );
//   }
// }

