import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';

import '../../../Services/dio_service.dart';
import '../../Models/api_response_model.dart';
import '../../Services/api_handler.dart';
import '../../const/urls.dart';
import '../Models/testimonial_model.dart';

Future<ApiResponse<
    List<TestimonialModel>
>> getTestimonials() async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler
      .handleRequest<
      List<TestimonialModel>>(

    request: () => di.get(
      kTestimonialsUrl,
    ),

    parser: (data) =>

        (data as List)

            .map(
              (e) =>
              TestimonialModel
                  .fromJson(e),
        )

            .toList(),
  );
}