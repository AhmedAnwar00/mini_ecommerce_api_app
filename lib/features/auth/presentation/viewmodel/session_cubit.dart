import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/core/network/unauthorized_notifier.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/user.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_state.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/data/profile_api.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required this.authRepository,
    required this.profileApi,
    required UnauthorizedNotifier unauthorizedNotifier,
  }) : super(const SessionLoading()) {
    _subscription = unauthorizedNotifier.onUnauthorized.listen((_) {
      expire();
    });
  }

  final AuthRepository authRepository;
  final ProfileApi profileApi;
  late final StreamSubscription<void> _subscription;
  Future<void> _queue = Future<void>.value();

  Future<void> start() {
    return _enqueue(_onStarted);
  }

  Future<void> signIn(User user) {
    return _enqueue(() async {
      _emit(SessionAuthenticated(user: user, signedInNow: true));
    });
  }

  Future<void> signOut() {
    return _enqueue(_onSignedOut);
  }

  Future<void> expire() {
    return _enqueue(() async {
      _emit(const SessionUnauthenticated());
    });
  }

  Future<void> _enqueue(Future<void> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.catchError((Object _) {});
    return result;
  }

  Future<void> _onStarted() async {
    _emit(const SessionLoading());
    String? token;
    try {
      token = await authRepository.readToken();
    } on Object {
      _emit(
        const SessionUnauthenticated(
          message: 'Saved login could not be read. Continuing as a guest.',
        ),
      );
      return;
    }
    if (token == null || token.isEmpty) {
      _emit(const SessionUnauthenticated());
      return;
    }
    try {
      final user = await profileApi.me();
      _emit(SessionAuthenticated(user: user, signedInNow: false));
    } on AppFailure catch (failure) {
      if (failure.kind == AppFailureKind.unauthorized) {
        _emit(const SessionUnauthenticated());
        return;
      }
      _emit(
        SessionAuthenticated(
          user: null,
          signedInNow: false,
          message: failure.message,
        ),
      );
    }
  }

  Future<void> _onSignedOut() async {
    try {
      await authRepository.clearSession();
    } on Object {
      _emit(const SessionUnauthenticated(signedOut: true));
      return;
    }
    _emit(const SessionUnauthenticated(signedOut: true));
  }

  void _emit(SessionState state) {
    if (isClosed) return;
    emit(state);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
