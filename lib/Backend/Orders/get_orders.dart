import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import 'package:pwt_website/const/urls.dart';
import '../../Models/Orders/order_model.dart';
import '../../Models/Pagination/paginated_response_model.dart';
import '../../Models/Pagination/pagination_model.dart';
import '../../Models/api_response_model.dart';

Future<ApiResponse<PaginatedResponse<OrderModel>>> getOrders({
  int page = 1,
  int perPage = 15,
  String? status,
  String? dateFrom,
  String? dateTo,
  String? sort,
  String? order,
}) async {
  final di = AppState.instance.dioService.dio;
  try {
    final response = await di.get(
      kOrdersUrl,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
        if (sort != null) 'sort': sort,
        if (order != null) 'order': order,
      },
    );
    final outer = response.data as Map<String, dynamic>;
    final dataMap = outer['data'] as Map<String, dynamic>;
    final meta = outer['meta'] as Map<String, dynamic>?;

    final orders = (dataMap['orders'] as List)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
print('666666666666666666666666666666666');
    return ApiResponse(
      success: outer['success'] ?? true,
      message: outer['message']?.toString(),
      data: PaginatedResponse<OrderModel>(
        items: orders,
        pagination: meta?['pagination'] != null
            ? PaginationModel.fromJson(meta!['pagination'])
            : null,
        meta: {'stats': dataMap['stats']},
      ),
    );
  } on dio.DioException catch (e) {
    final data = e.response?.data;
    return ApiResponse(
      success: false,
      message: data?['message']?.toString(),
      error: data?['error']?.toString(),
    );
  } catch (e) {
    return ApiResponse(success: false, message: e.toString());
  }
}
