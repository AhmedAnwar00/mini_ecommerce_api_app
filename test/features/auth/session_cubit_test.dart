import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/core/network/unauthorized_notifier.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/token_storage.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_api.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_session.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/login_request.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/user.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_state.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/data/profile_api.dart';

const _user = User(
  id: 'u1',
  name: 'Ada',
  email: 'ada@example.com',
  membershipBasisPoints: 500,
);

void main() {
  test('starts loading', () async {
    final harness = _Harness();

    expect(harness.cubit.state, isA<SessionLoading>());
    await harness.close();
  });

  test('continues as a guest when no token is saved', () async {
    final harness = _Harness();

    await harness.cubit.start();

    final state = harness.cubit.state as SessionUnauthenticated;
    expect(state.message, isNull);
    expect(state.signedOut, isFalse);
    await harness.close();
  });

  test('continues as a guest when the saved token is empty', () async {
    final harness = _Harness(token: '');

    await harness.cubit.start();

    expect(harness.cubit.state, isA<SessionUnauthenticated>());
    await harness.close();
  });

  test('continues as a guest when the saved token cannot be read', () async {
    final harness = _Harness(tokenError: StateError('disk'));

    await harness.cubit.start();

    expect(
      (harness.cubit.state as SessionUnauthenticated).message,
      'Saved login could not be read. Continuing as a guest.',
    );
    await harness.close();
  });

  test('restores a saved session without marking a fresh sign-in', () async {
    final harness = _Harness(token: 'token-1');

    await harness.cubit.start();

    final state = harness.cubit.state as SessionAuthenticated;
    expect(state.user, _user);
    expect(state.signedInNow, isFalse);
    expect(state.message, isNull);
    await harness.close();
  });

  test('drops a saved token when the profile is unauthorized', () async {
    final harness = _Harness(
      token: 'token-1',
      failure: const AppFailure(AppFailureKind.unauthorized, 'Expired'),
    );

    await harness.cubit.start();

    final state = harness.cubit.state as SessionUnauthenticated;
    expect(state.signedOut, isFalse);
    expect(state.message, isNull);
    await harness.close();
  });

  test('keeps a guest profile message when startup fails', () async {
    final harness = _Harness(
      token: 'token-1',
      failure: const AppFailure(AppFailureKind.network, 'Offline'),
    );

    await harness.cubit.start();

    final state = harness.cubit.state as SessionAuthenticated;
    expect(state.user, isNull);
    expect(state.signedInNow, isFalse);
    expect(state.message, 'Offline');
    await harness.close();
  });

  test('marks a fresh sign-in', () async {
    final harness = _Harness();

    await harness.cubit.signIn(_user);

    final state = harness.cubit.state as SessionAuthenticated;
    expect(state.user, _user);
    expect(state.signedInNow, isTrue);
    await harness.close();
  });

  test('clears the session on sign-out', () async {
    final harness = _Harness(token: 'token-1');

    await harness.cubit.signOut();

    final state = harness.cubit.state as SessionUnauthenticated;
    expect(state.signedOut, isTrue);
    expect(harness.tokens.value, isNull);
    await harness.close();
  });

  test('still signs out when clearing the session fails', () async {
    final harness = _Harness(token: 'token-1', clearError: StateError('disk'));

    await harness.cubit.signOut();

    expect(
      (harness.cubit.state as SessionUnauthenticated).signedOut,
      isTrue,
    );
    await harness.close();
  });

  test('expires without marking a sign-out', () async {
    final harness = _Harness(token: 'token-1');
    await harness.cubit.signIn(_user);

    await harness.cubit.expire();

    final state = harness.cubit.state as SessionUnauthenticated;
    expect(state.signedOut, isFalse);
    expect(harness.tokens.value, 'token-1');
    await harness.close();
  });

  test('expires when the api reports unauthorized', () async {
    final harness = _Harness(token: 'token-1');
    await harness.cubit.signIn(_user);

    harness.notifier.notify();
    await harness.cubit.stream.firstWhere(
      (state) => state is SessionUnauthenticated,
    );

    expect(
      (harness.cubit.state as SessionUnauthenticated).signedOut,
      isFalse,
    );
    await harness.close();
  });

  test('an expiry during startup wins over the restored user', () async {
    final gate = Completer<User>();
    final harness = _Harness(token: 'token-1', userGate: gate);
    final started = harness.cubit.start();
    final expired = harness.cubit.expire();

    gate.complete(_user);
    await started;
    await expired;

    final state = harness.cubit.state as SessionUnauthenticated;
    expect(state.signedOut, isFalse);
    await harness.close();
  });
}

class _Harness {
  _Harness({
    String? token,
    Object? tokenError,
    Object? clearError,
    AppFailure? failure,
    Completer<User>? userGate,
  }) : tokens = _FakeTokenStorage(token, tokenError, clearError),
       notifier = UnauthorizedNotifier() {
    cubit = SessionCubit(
      authRepository: AuthRepository(_UnusedAuthApi(), tokens),
      profileApi: _FakeProfileApi(failure: failure, userGate: userGate),
      unauthorizedNotifier: notifier,
    );
  }

  final _FakeTokenStorage tokens;
  final UnauthorizedNotifier notifier;
  late final SessionCubit cubit;

  Future<void> close() async {
    await cubit.close();
    await notifier.dispose();
  }
}

class _FakeTokenStorage implements TokenStorage {
  _FakeTokenStorage(this.value, this.readError, this.clearError);

  String? value;
  final Object? readError;
  final Object? clearError;

  @override
  Future<void> clear() async {
    final error = clearError;
    if (error != null) throw error;
    value = null;
  }

  @override
  Future<String?> read() async {
    final error = readError;
    if (error != null) throw error;
    return value;
  }

  @override
  Future<void> write(String token) async {
    value = token;
  }
}

class _UnusedAuthApi implements AuthApi {
  @override
  Future<AuthSession> login(LoginRequest request) {
    throw UnimplementedError();
  }
}

class _FakeProfileApi implements ProfileApi {
  _FakeProfileApi({this.failure, this.userGate});

  final AppFailure? failure;
  final Completer<User>? userGate;

  @override
  Future<User> me() async {
    final gate = userGate;
    if (gate != null) return gate.future;
    final error = failure;
    if (error != null) throw error;
    return _user;
  }
}
