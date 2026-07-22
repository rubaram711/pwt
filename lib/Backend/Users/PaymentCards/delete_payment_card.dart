import 'package:dio/dio.dart' as dio;
import '../../../myWeb2/state/app_state.dart';
import '../../../const/urls.dart';
import '../../../Models/api_response_model.dart';
import '../../../Services/api_handler.dart';

Future<ApiResponse<DeletePaymentCardResponse>> deletePaymentCard(int id) async {
  final dio.Dio di = AppState.instance.dioService.dio;

  return ApiHandler.handleRequest<DeletePaymentCardResponse>(
    request: () => di.delete('$kPaymentCardsUrl/$id'),
    parser: (data) => DeletePaymentCardResponse.fromJson(data),
  );
}

class DeletePaymentCardResponse {
  final int id;
  final String deletedAt;

  DeletePaymentCardResponse({required this.id, required this.deletedAt});

  factory DeletePaymentCardResponse.fromJson(Map<String, dynamic> json) {
    return DeletePaymentCardResponse(
      id: json['id'],
      deletedAt: json['deleted_at'] ?? '',
    );
  }
}
