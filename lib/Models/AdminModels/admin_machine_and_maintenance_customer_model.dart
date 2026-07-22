class AdminMachineAndMaintenanceCustomerModel {

  final int? id;

  final String? name;

  AdminMachineAndMaintenanceCustomerModel({
    this.id,
    this.name,
  });

  factory AdminMachineAndMaintenanceCustomerModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return AdminMachineAndMaintenanceCustomerModel();
    }

    return AdminMachineAndMaintenanceCustomerModel(

      id: json['id'],

      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'name': name,
    };
  }
}