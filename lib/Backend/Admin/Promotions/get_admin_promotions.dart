import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Promotions/admin_promotion_model.dart';
import '../../../Models/Pagination/paginated_response_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/dio_service.dart';
import '../../../Services/paginated_api_handler.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        PaginatedResponse<
            AdminPromotionModel
        >
    >
> getAdminPromotions({

  int page = 1,

  int perPage = 15,

  String? search,

  String? type,

  String? appliesTo,

  bool? isActive,

  String? status,

  String? startsBefore,

  String? startsAfter,

  String? endsBefore,

  String? endsAfter,

  bool? includeTrashed,

  String? sort,

  String? order,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return PaginatedApiHandler
      .handleRequest<

      AdminPromotionModel

  >(

    request: () => di.get(

      kAdminPromotionsUrl,

      queryParameters: {

        'page': page,

        'per_page': perPage,

        if (search != null)
          'search': search,

        if (type != null)
          'type': type,

        if (appliesTo != null)
          'applies_to':
          appliesTo,

        if (isActive != null)
          'is_active': isActive,

        if (status != null)
          'status': status,

        if (startsBefore != null)
          'starts_before':
          startsBefore,

        if (startsAfter != null)
          'starts_after':
          startsAfter,

        if (endsBefore != null)
          'ends_before':
          endsBefore,

        if (endsAfter != null)
          'ends_after':
          endsAfter,

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
        AdminPromotionModel
            .fromJson(item),
  );
}