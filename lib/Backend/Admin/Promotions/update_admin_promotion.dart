import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';

import '../../../Models/AdminModels/Promotions/admin_promotion_update_model.dart';
import '../../../Models/api_response_model.dart';
import '../../../Models/translation_model.dart';
import '../../../Services/api_handler.dart';
import '../../../Services/dio_service.dart';
import '../../../const/urls.dart';

Future<
    ApiResponse<
        AdminPromotionUpdateModel
    >
> updateAdminPromotion({

  required int promotionId,

  TranslationModel? name,

  TranslationModel? description,

  String? type,

  num? value,

  num? maxDiscountAmount,

  num? minOrderAmount,

  String? currency,

  String? appliesTo,

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

      AdminPromotionUpdateModel

  >(

    request: () => di.put(

      '$kAdminPromotionsUrl/$promotionId',

      data: {

        if (name != null)
          'name': name.toJson(),

        if (description != null)
          'description':
          description.toJson(),

        if (type != null)
          'type': type,

        if (value != null)
          'value': value,

        if (maxDiscountAmount != null)
          'max_discount_amount':
          maxDiscountAmount,

        if (minOrderAmount != null)
          'min_order_amount':
          minOrderAmount,

        if (currency != null)
          'currency': currency,

        if (appliesTo != null)
          'applies_to':
          appliesTo,

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
        AdminPromotionUpdateModel
            .fromJson(data),
  );
}