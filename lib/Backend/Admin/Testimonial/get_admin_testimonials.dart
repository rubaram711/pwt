import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Testimonial/admin_testimonial_model.dart';
import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<
            AdminTestimonialModel
        >
    >
> getAdminTestimonials({

  int page = 1,

  int perPage = 15,

  String? search,

  bool? isActive,

  int? rating,

  int? ratingMin,

  int? ratingMax,

  bool? includeTrashed,

  String? sort,

  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<

      AdminTestimonialModel

  >(

    request: () => di.get(

      kAdminTestimonialsUrl,

      queryParameters: {

        'page': page,

        'per_page': perPage,

        if (search != null)
          'search': search,

        if (isActive != null)
          'is_active': isActive,

        if (rating != null)
          'rating': rating,

        if (ratingMin != null)
          'rating_min': ratingMin,

        if (ratingMax != null)
          'rating_max': ratingMax,

        if (includeTrashed != null)
          'include_trashed':
          includeTrashed,

        if (sort != null)
          'sort': sort,

        if (order != null)
          'order': order,
      },
    ),

    itemParser: (item) =>
        AdminTestimonialModel
            .fromJson(item),
  );
}