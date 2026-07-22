
import '../Models/api_response_model.dart';



String getErrorMessage(ApiResponse response) {

  /// validation errors
  if (response.errors != null &&
      response.errors!.isNotEmpty) {

    final firstValue =
        response.errors!.values.first;

    if (firstValue.isNotEmpty) {
      return firstValue.first;
    }
  }

  /// backend general error
  if (response.error != null &&
      response.error!.isNotEmpty) {

    return response.error!;
  }

  /// fallback message
  if (response.message != null &&
      response.message!.isNotEmpty) {

    return response.message!;
  }

  return 'error_message';
}