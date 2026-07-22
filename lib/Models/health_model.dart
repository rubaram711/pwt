class HealthModel {

  final String? status;
  final String? service;
  final String? time;

  HealthModel({
    this.status,
    this.service,
    this.time,
  });

  factory HealthModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return HealthModel();
    }

    return HealthModel(
      status: json['status'],
      service: json['service'],
      time: json['time'],
    );
  }
}