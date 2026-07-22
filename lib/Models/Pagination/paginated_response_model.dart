import 'pagination_model.dart';

class PaginatedResponse<T> {

  final List<T> items;
  final PaginationModel? pagination;
  final Map<String, dynamic>? meta;

  PaginatedResponse({
    required this.items,
    this.pagination,
    this.meta,
  });
}