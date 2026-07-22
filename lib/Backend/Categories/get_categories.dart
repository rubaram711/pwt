import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../../Services/dio_service.dart';
import '../../Models/api_response_model.dart';
import '../../Models/category_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';

Future<ApiResponse<List<CategoryModel>>>
getCategories({
  String? search,
}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<List<CategoryModel>>(

    request: () => di.get(

      kCategoriesUrl,

      queryParameters: {

        if (search != null)
          "search": search,
      },
    ),

    parser: (data) =>
        (data as List)
            .map(
              (e) => CategoryModel.fromJson(e),
        )
            .toList(),
  );
}