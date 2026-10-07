import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/token_storage.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_api.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_session.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/login_request.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/user.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/login_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/login_state.dart';

const _user = User(
  id: 'u1',
  name: 'Ada',
  email: 'ada@example.com',
  membershipBasisPoints: 500,
);

void main() {
  test('starts idle', () async {
    final cubit = LoginCubit(_repository());

    expect(cubit.state, isA<LoginIdle>());
    await cubit.close();
  });

  test('rejects a blank email or password', () async {
    final api = _FakeAuthApi(
      session: const AuthSession(token: 't', user: _user),
    );
    final cubit = LoginCubit(AuthRepository(api, _FakeTokenStorage()));

    await cubit.submit(const LoginRequest(email: '   ', password: 'secret'));

    expect(
      (cubit.state as LoginFailure).message,
      'Enter your email and password.',
    );
    expect(api.calls, 0);

    await cubit.submit(
      const LoginRequest(email: 'ada@example.com', password: ''),
    );

    expect(
      (cubit.state as LoginFailure).message,
      'Enter your email and password.',
    );
    expect(api.calls, 0);
    await cubit.close();
  });

  test('emits submitting then the signed-in user', () async {
    final cubit = LoginCubit(_repository());
    final states = cubit.stream.take(2).toList();

    await cubit.submit(
      const LoginRequest(email: ' ada@example.com ', password: 'secret'),
    );

    final emitted = await states;
    expect(emitted[0], isA<LoginSubmitting>());
    final success = emitted[1] as LoginSuccess;
    expect(success.user.id, _user.id);
    expect(success.user.email, _user.email);
    await cubit.close();
  });

  test('emits a failure message from the repository', () async {
    final cubit = LoginCubit(
      _repository(
        failure: const AppFailure(AppFailureKind.unauthorized, 'Invalid login'),
      ),
    );

    await cubit.submit(
      const LoginRequest(email: 'ada@example.com', password: 'secret'),
    );

    expect((cubit.state as LoginFailure).message, 'Invalid login');
    await cubit.close();
  });
}

AuthRepository _repository({AppFailure? failure}) {
  return AuthRepository(
    _FakeAuthApi(
      session: const AuthSession(token: 'token-1', user: _user),
      failure: failure,
    ),
    _FakeTokenStorage(),
  );
}

class _FakeTokenStorage implements TokenStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String token) async {}
}

class _FakeAuthApi implements AuthApi {
  _FakeAuthApi({required this.session, this.failure});

  final AuthSession session;
  final AppFailure? failure;
  int calls = 0;

  @override
  Future<AuthSession> login(LoginRequest request) async {
    calls++;
    final failure = this.failure;
    if (failure != null) throw failure;
    return session;
  }
}
