import '../../../Pagination/pagination_model.dart';
import 'maintenance_report_summary_model.dart';

class MaintenanceReportModel {

  final MaintenanceReportSummaryModel?
  summary;

  final List<dynamic>? rows;

  final PaginationModel? pagination;

  MaintenanceReportModel({

    this.summary,

    this.rows,

    this.pagination,
  });

  factory
  MaintenanceReportModel.fromJson(

      Map<String, dynamic>? json,

      Map<String, dynamic>? meta,
      ) {

    return MaintenanceReportModel(

      summary:
      MaintenanceReportSummaryModel
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