import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Banner/admin_banner_update_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Models/translation_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminBannerUpdateModel
    >
> updateAdminBanner({

  required int bannerId,

  String? placement,

  TranslationModel? title,

  TranslationModel? subtitle,

  String? imageUrl,

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

      AdminBannerUpdateModel

  >(

    request: () => di.put(

      '$kAdminBannersUrl/$bannerId',

      data: {

        if (placement != null)
          'placement': placement,

        if (title != null)
          'title': title.toJson(),

        if (subtitle != null)
          'subtitle':
          subtitle.toJson(),

        if (imageUrl != null)
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
        AdminBannerUpdateModel
            .fromJson(data),
  );
}