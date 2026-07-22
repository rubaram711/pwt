class AdminUserModel {

  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? phoneCountryCode;

  final String? role;

  final String? lastLoginAt;
  final String? createdAt;

  AdminUserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.phoneCountryCode,
    this.role,
    this.lastLoginAt,
    this.createdAt,
  });

  factory AdminUserModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminUserModel(

      id: json['id'],

      name: json['name'],

      email: json['email'],

      phone: json['phone'],

      phoneCountryCode:
      json['phone_country_code'],

      role: json['role'],

      lastLoginAt:
      json['last_login_at'],

      createdAt:
      json['created_at'],
    );
  }
}