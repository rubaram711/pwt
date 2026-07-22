import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Testimonial/admin_testimonial_delete_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminTestimonialDeleteModel
    >
> deleteAdminTestimonial({

  required int testimonialId,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminTestimonialDeleteModel

  >(

    request: () => di.delete(

      '$kAdminTestimonialsUrl/$testimonialId',
    ),

    parser: (data) =>
        AdminTestimonialDeleteModel
            .fromJson(data),
  );
}