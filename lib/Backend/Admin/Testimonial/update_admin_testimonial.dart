import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Testimonial/admin_testimonial_update_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Models/translation_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminTestimonialUpdateModel
    >
> updateAdminTestimonial({

  required int testimonialId,

  String? name,

  String? role,

  String? company,

  int? rating,

  TranslationModel? quote,

  String? avatarUrl,

  int? displayOrder,

  bool? isActive,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminTestimonialUpdateModel

  >(

    request: () => di.put(

      '$kAdminTestimonialsUrl/$testimonialId',

      data: {

        if (name != null)
          'name': name,

        if (role != null)
          'role': role,

        if (company != null)
          'company': company,

        if (rating != null)
          'rating': rating,

        if (quote != null)
          'quote':
          quote.toJson(),

        if (avatarUrl != null)
          'avatar_url':
          avatarUrl,

        if (displayOrder != null)
          'display_order':
          displayOrder,

        if (isActive != null)
          'is_active': isActive,
      },
    ),

    parser: (data) =>
        AdminTestimonialUpdateModel
            .fromJson(data),
  );
}