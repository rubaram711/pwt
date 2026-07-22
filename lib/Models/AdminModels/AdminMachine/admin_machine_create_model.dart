class AdminMachineCreateModel {

  final int? id;

  final String? serialNumber;
  final String? source;

  final bool? isActive;

  AdminMachineCreateModel({
    this.id,
    this.serialNumber,
    this.source,
    this.isActive,
  });

  factory AdminMachineCreateModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminMachineCreateModel(

      id: json['id'],

      serialNumber:
      json['serial_number'],

      source:
      json['source'],

      isActive:
      json['is_active'],
    );
  }
}