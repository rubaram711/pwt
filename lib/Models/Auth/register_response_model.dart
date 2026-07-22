import 'user_model.dart';
import 'token_model.dart';

class AuthResponse {
  final User user;
  final TokenModel token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: TokenModel.fromJson(json['token']),
    );
  }
}