import 'package:mini_ecommerce_app_prompt/core/storage/token_storage.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_api.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/login_request.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/user.dart';

class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final AuthApi _api;
  final TokenStorage _tokens;

  Future<User> login(LoginRequest request) async {
    final session = await _api.login(request);
    await _tokens.write(session.token);
    return session.user;
  }

  Future<String?> readToken() => _tokens.read();

  Future<void> clearSession() => _tokens.clear();
}
