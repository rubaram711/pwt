import '../../../Pagination/pagination_model.dart';
import 'sales_report_bucket_model.dart';
import 'sales_report_summary_model.dart';

class SalesReportModel {

  final SalesReportSummaryModel?
  summary;

  final List<SalesReportBucketModel>?
  buckets;

  final List<dynamic>? rows;

  final PaginationModel? pagination;

  SalesReportModel({

    this.summary,

    this.buckets,

    this.rows,

    this.pagination,
  });

  factory SalesReportModel.fromJson(
      Map<String, dynamic>? json,
      Map<String, dynamic>? meta,
      ) {

    return SalesReportModel(

      summary:
      SalesReportSummaryModel
          .fromJson(
        json?['summary'],
      ),

      buckets:
      (json?['buckets'] as List?)

          ?.map(
            (e) =>
            SalesReportBucketModel
                .fromJson(e),
      )

          .toList(),

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