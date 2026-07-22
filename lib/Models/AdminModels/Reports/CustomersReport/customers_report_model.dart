import '../../../Pagination/pagination_model.dart';
import 'customers_report_summary_model.dart';

class CustomersReportModel {

  final CustomersReportSummaryModel?
  summary;

  final List<dynamic>? rows;

  final PaginationModel? pagination;

  CustomersReportModel({

    this.summary,

    this.rows,

    this.pagination,
  });

  factory CustomersReportModel
      .fromJson(

      Map<String, dynamic>? json,

      Map<String, dynamic>? meta,
      ) {

    return CustomersReportModel(

      summary:
      CustomersReportSummaryModel
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