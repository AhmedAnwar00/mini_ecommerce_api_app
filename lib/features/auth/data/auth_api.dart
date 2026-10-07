import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_session.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/login_request.dart';

abstract class AuthApi {
  Future<AuthSession> login(LoginRequest request);
}
