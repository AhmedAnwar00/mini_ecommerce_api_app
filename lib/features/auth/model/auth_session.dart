import 'package:mini_ecommerce_app_prompt/features/auth/model/user.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final user = json['user'];
    if (token is! String || token.isEmpty || user is! Map) {
      throw const FormatException('Auth session is incomplete');
    }
    return AuthSession(
      token: token,
      user: User.fromJson(Map<String, dynamic>.from(user)),
    );
  }
}
