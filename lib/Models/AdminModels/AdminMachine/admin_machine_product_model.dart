class AdminMachineProductModel {

  final int? id;
  final String? code;

  AdminMachineProductModel({
    this.id,
    this.code,
  });

  factory AdminMachineProductModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminMachineProductModel(
      id: json['id'],
      code: json['code'],
    );
  }
}