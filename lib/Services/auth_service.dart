// import 'package:get_storage/get_storage.dart';
//
// import '../Models/Auth/register_response_model.dart';
// import '../Models/Auth/user_model.dart';
//
// class AuthService {
//   final GetStorage _box = GetStorage();
//
//   static const _tokenKey = 'token';
//   static const _userKey = 'user';
//
//   /// Save login data
//   void saveLogin(AuthResponse data) {
//     _box.write(_tokenKey, data.token.accessToken);
//     _box.write(_userKey, data.user.toJson());
//   }
//
//   /// Get token
//   String? get token => _box.read(_tokenKey);
//
//   /// Get user
//   User? get user {
//     final json = _box.read(_userKey);
//     if (json == null) return null;
//     return User.fromJson(Map<String, dynamic>.from(json));
//   }
//
//   /// Logged in?
//   bool get isLoggedIn => token != null;
//
//   /// Logout
//   void logout() {
//     _box.erase();
//   }
// }
