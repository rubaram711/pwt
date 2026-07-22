import 'package:dio/dio.dart' as dio;
import '../../myWeb2/state/app_state.dart';
import 'package:pwt_website/const/urls.dart';
import '../../Models/Machines/machines_model.dart';
import '../../Models/Pagination/paginated_response_model.dart';
import '../../Models/Pagination/pagination_model.dart';
import '../../Models/api_response_model.dart';

Future<ApiResponse<PaginatedResponse<MachineModel>>> getMachines({
  int page = 1,
  int perPage = 15,
  String? term,
  String? status,
  String? search,
  bool? needsMaintenance,
  String? countryCode,
  bool? isActive,
  String? sort,
  String? order,
}) async {
  final di = AppState.instance.dioService.dio;
  try {
    final response = await di.get(kMachinesUrl, queryParameters: {
      'page': page, 'per_page': perPage,
      if (term != null) 'term': term,
      if (status != null) 'status': status,
      if (search != null) 'search': search,
      if (needsMaintenance != null) 'needs_maintenance': needsMaintenance,
      if (countryCode != null) 'country_code': countryCode,
      if (isActive != null) 'is_active': isActive,
      if (sort != null) 'sort': sort,
      if (order != null) 'order': order,
    });
    final outer   = response.data as Map<String, dynamic>;
    final dataMap = outer['data'] as Map<String, dynamic>;
    final meta    = outer['meta'] as Map<String, dynamic>?;
    final machines = (dataMap['machines'] as List)
        .map((e) => MachineModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ApiResponse(
      success: outer['success'] ?? true,
      message: outer['message']?.toString(),
      data: PaginatedResponse<MachineModel>(
        items: machines,
        pagination: meta?['pagination'] != null
            ? PaginationModel.fromJson(meta!['pagination'] as Map<String, dynamic>)
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
