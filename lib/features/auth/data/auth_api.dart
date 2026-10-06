import 'package:mini_ecommerce_app_prompt/features/auth/model/auth_session.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/model/login_request.dart';

abstract class AuthApi {
  Future<AuthSession> login(LoginRequest request);
}
