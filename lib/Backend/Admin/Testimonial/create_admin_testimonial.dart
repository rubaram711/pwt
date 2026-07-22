import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Testimonial/admin_testimonial_create_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Models/translation_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminTestimonialCreateModel
    >
> createAdminTestimonial({

  required String name,

  String? role,

  String? company,

  required int rating,

  required TranslationModel quote,

  String? avatarUrl,

  int? displayOrder,

  bool? isActive,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminTestimonialCreateModel

  >(

    request: () => di.post(

      kAdminTestimonialsUrl,

      data: {

        'name': name,

        if (role != null)
          'role': role,

        if (company != null)
          'company': company,

        'rating': rating,

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
        AdminTestimonialCreateModel
            .fromJson(data),
  );
}