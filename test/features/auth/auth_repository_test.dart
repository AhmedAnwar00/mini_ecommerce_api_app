import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app_prompt/core/storage/token_storage.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_api.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/model/auth_session.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/model/login_request.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/model/user.dart';

void main() {
  test('login stores the token and returns the user', () async {
    final tokens = FakeTokenStorage();
    final repository = AuthRepository(
      FakeAuthApi(
        const AuthSession(
          token: 'token-1',
          user: User(
            id: 'u1',
            name: 'Ada',
            email: 'ada@shop.test',
            membershipBasisPoints: 1000,
          ),
        ),
      ),
      tokens,
    );

    final user = await repository.login(
      const LoginRequest(email: 'ada@shop.test', password: 'secret'),
    );

    expect(user.id, 'u1');
    expect(tokens.value, 'token-1');
    expect(await repository.readToken(), 'token-1');

    await repository.clearSession();
    expect(tokens.value, isNull);
  });
}

class FakeTokenStorage implements TokenStorage {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String token) async => value = token;

  @override
  Future<void> clear() async => value = null;
}

class FakeAuthApi implements AuthApi {
  FakeAuthApi(this.session);

  final AuthSession session;

  @override
  Future<AuthSession> login(LoginRequest request) async => session;
}
