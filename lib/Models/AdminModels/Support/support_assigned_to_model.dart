class SupportAssignedToModel {

  final int? id;

  final String? name;

  SupportAssignedToModel({
    this.id,
    this.name,
  });

  factory SupportAssignedToModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return SupportAssignedToModel();
    }

    return SupportAssignedToModel(

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