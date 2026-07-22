class MaintenanceMachineModel {

  final int? id;

  final String? serialNumber;

  MaintenanceMachineModel({
    this.id,
    this.serialNumber,
  });

  factory MaintenanceMachineModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return MaintenanceMachineModel();
    }

    return MaintenanceMachineModel(

      id: json['id'],

      serialNumber: json['serial_number'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'serial_number': serialNumber,
    };
  }
}