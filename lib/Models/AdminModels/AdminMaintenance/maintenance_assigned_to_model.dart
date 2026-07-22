class MaintenanceAssignedToModel {

  final int? id;

  final String? name;

  MaintenanceAssignedToModel({
    this.id,
    this.name,
  });

  factory MaintenanceAssignedToModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return MaintenanceAssignedToModel();
    }

    return MaintenanceAssignedToModel(

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