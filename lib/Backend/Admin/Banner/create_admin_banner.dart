import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Banner/admin_banner_create_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Models/translation_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminBannerCreateModel
    >
> createAdminBanner({

  required String code,

  required String placement,

  required TranslationModel title,

  TranslationModel? subtitle,

  required String imageUrl,

  String? imageUrlAr,

  TranslationModel? ctaLabel,

  String? ctaUrl,

  String? startsAt,

  String? endsAt,

  int? displayOrder,

  bool? isActive,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminBannerCreateModel

  >(

    request: () => di.post(

      kAdminBannersUrl,

      data: {

        'code': code,

        'placement': placement,

        'title': title.toJson(),

        if (subtitle != null)
          'subtitle':
          subtitle.toJson(),

        'image_url': imageUrl,

        if (imageUrlAr != null)
          'image_url_ar':
          imageUrlAr,

        if (ctaLabel != null)
          'cta_label':
          ctaLabel.toJson(),

        if (ctaUrl != null)
          'cta_url': ctaUrl,

        if (startsAt != null)
          'starts_at': startsAt,

        if (endsAt != null)
          'ends_at': endsAt,

        if (displayOrder != null)
          'display_order':
          displayOrder,

        if (isActive != null)
          'is_active': isActive,
      },
    ),

    parser: (data) =>
        AdminBannerCreateModel
            .fromJson(data),
  );
}