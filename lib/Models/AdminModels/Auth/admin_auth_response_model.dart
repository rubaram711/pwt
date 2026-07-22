import '../../Auth/token_model.dart';
import 'admin_user_model.dart';
import 'admin_capabilities_model.dart';

class AdminAuthResponseModel {

  final AdminUserModel user;

  final TokenModel token;

  final String role;

  final List<String> permissions;

  final AdminCapabilitiesModel capabilities;

  AdminAuthResponseModel({
    required this.user,
    required this.token,
    required this.role,
    required this.permissions,
    required this.capabilities,
  });

  factory AdminAuthResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return AdminAuthResponseModel(

      user: AdminUserModel.fromJson(
        json['user'],
      ),

      token: TokenModel.fromJson(
        json['token'],
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