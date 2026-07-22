import '../../../Pagination/pagination_model.dart';
import 'orders_report_summary_model.dart';

class OrdersReportModel {

  final OrdersReportSummaryModel?
  summary;

  final List<dynamic>? rows;

  final PaginationModel? pagination;

  OrdersReportModel({

    this.summary,

    this.rows,

    this.pagination,
  });

  factory OrdersReportModel.fromJson(

      Map<String, dynamic>? json,

      Map<String, dynamic>? meta,
      ) {

    return OrdersReportModel(

      summary:
      OrdersReportSummaryModel
          .fromJson(
        json?['summary'],
      ),

      rows: json?['rows'],

      pagination:
      meta?['pagination'] != null

          ? PaginationModel.fromJson(
        meta?['pagination'],
      )

          : null,
    );
  }
}