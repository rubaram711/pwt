import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Promotions/admin_promotion_create_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Models/translation_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminPromotionCreateModel
    >
> createAdminPromotion({

  required String code,

  required TranslationModel name,

  TranslationModel? description,

  required String type,

  required num value,

  num? maxDiscountAmount,

  num? minOrderAmount,

  String? currency,

  required String appliesTo,

  List<int>? productIds,

  List<int>? categoryIds,

  String? startsAt,

  String? endsAt,

  int? perUserLimit,

  int? totalLimit,

  bool? isActive,

}) async {

final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<

      AdminPromotionCreateModel

  >(

    request: () => di.post(

      kAdminPromotionsUrl,

      data: {

        'code': code,

        'name': name.toJson(),

        if (description != null)
          'description':
          description.toJson(),

        'type': type,

        'value': value,

        if (maxDiscountAmount != null)
          'max_discount_amount':
          maxDiscountAmount,

        if (minOrderAmount != null)
          'min_order_amount':
          minOrderAmount,

        if (currency != null)
          'currency': currency,

        'applies_to': appliesTo,

        if (productIds != null)
          'product_ids':
          productIds,

        if (categoryIds != null)
          'category_ids':
          categoryIds,

        if (startsAt != null)
          'starts_at': startsAt,

        if (endsAt != null)
          'ends_at': endsAt,

        if (perUserLimit != null)
          'per_user_limit':
          perUserLimit,

        if (totalLimit != null)
          'total_limit':
          totalLimit,

        if (isActive != null)
          'is_active': isActive,
      },
    ),

    parser: (data) =>
        AdminPromotionCreateModel
            .fromJson(data),
  );
}