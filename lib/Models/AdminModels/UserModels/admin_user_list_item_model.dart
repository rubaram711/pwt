import 'user_counts_model.dart';

class AdminUserListItemModel {

  final int? id;

  final String? name;
  final String? email;
  final String? phone;

  final String? phoneCountryCode;

  final String? locale;

  final bool? isActive;

  final String? role;

  final UserCountsModel? counts;

  final String? lastLoginAt;

  final String? createdAt;

  final String? deletedAt;

  AdminUserListItemModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.phoneCountryCode,
    this.locale,
    this.isActive,
    this.role,
    this.counts,
    this.lastLoginAt,
    this.createdAt,
    this.deletedAt,
  });

  factory AdminUserListItemModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminUserListItemModel(

      id: json['id'],

      name: json['name'],

      email: json['email'],

      phone: json['phone'],

      phoneCountryCode:
      json['phone_country_code'],

      locale: json['locale'],

      isActive: json['is_active'],

      role: json['role'],

      counts:
      json['counts'] != null

          ? UserCountsModel.fromJson(
        json['counts'],
      )

          : null,

      lastLoginAt:
      json['last_login_at'],

      createdAt:
      json['created_at'],

      deletedAt:
      json['deleted_at'],
    );
  }
}