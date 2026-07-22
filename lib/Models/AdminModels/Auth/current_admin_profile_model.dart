import 'admin_capabilities_model.dart';
import 'admin_user_model.dart';

class CurrentAdminProfileModel {

  final AdminUserModel user;

  final String role;

  final List<String> permissions;

  final AdminCapabilitiesModel capabilities;

  CurrentAdminProfileModel({
    required this.user,
    required this.role,
    required this.permissions,
    required this.capabilities,
  });

  factory CurrentAdminProfileModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return CurrentAdminProfileModel(

      user: AdminUserModel.fromJson(
        json['user'],
      ),

      role: json['role'] ?? '',

      permissions:
      List<String>.from(
        json['permissions'] ?? [],
      ),

      capabilities:
      AdminCapabilitiesModel.fromJson(
        json['capabilities'] ?? {},
      ),
    );
  }
}