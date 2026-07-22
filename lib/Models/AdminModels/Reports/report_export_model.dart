class ReportExportModel {

  final List<int>? bytes;

  final String? contentType;

  final String? fileName;

  final bool? isTruncated;

  final String? rowCount;

  ReportExportModel({

    this.bytes,

    this.contentType,

    this.fileName,

    this.isTruncated,

    this.rowCount,
  });
}