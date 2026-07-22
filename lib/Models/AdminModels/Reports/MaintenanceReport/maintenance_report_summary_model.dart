class MaintenanceReportSummaryModel {

  final int? newCount;

  final int? assigned;

  final int? inProgress;

  final int? completed;

  final int? cancelled;

  MaintenanceReportSummaryModel({

    this.newCount,

    this.assigned,

    this.inProgress,

    this.completed,

    this.cancelled,
  });

  factory
  MaintenanceReportSummaryModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return
        MaintenanceReportSummaryModel();
    }

    return
      MaintenanceReportSummaryModel(

        newCount: json['new'],

        assigned:
        json['assigned'],

        inProgress:
        json['in_progress'],

        completed:
        json['completed'],

        cancelled:
        json['cancelled'],
      );
  }
}