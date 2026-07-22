class UpdateUserResponseModel {

  final int? id;

  final String? name;

  final String? email;

  final String? role;

  final bool? isActive;

  UpdateUserResponseModel({
    this.id,
    this.name,
    this.email,
    this.role,
    this.isActive,
  });

  factory UpdateUserResponseModel
      .fromJson(
      Map<String, dynamic> json,
      ) {

    return UpdateUserResponseModel(

      id: json['id'],

      name: json['name'],

      email: json['email'],

      role: json['role'],

      isActive:
      json['is_active'],
    );
  }
}