class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? error;
  final String? code;
  final T? data;
  final Map<String, List<String>>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.error,
    this.code,
    this.data,
    this.errors,
  });
}