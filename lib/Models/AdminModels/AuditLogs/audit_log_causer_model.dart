class AuditLogCauserModel {

  final int? id;

  final String? name;

  final String? role;

  AuditLogCauserModel({

    this.id,

    this.name,

    this.role,
  });

  factory AuditLogCauserModel
      .fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return AuditLogCauserModel();
    }

    return AuditLogCauserModel(

      id: json['id'],

      name: json['name'],

      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'name': name,

      'role': role,
    };
  }
}