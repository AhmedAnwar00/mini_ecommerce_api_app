import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/core/network/unauthorized_notifier.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_event.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_state.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/data/profile_api.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({
    required this.authRepository,
    required this.profileApi,
    required UnauthorizedNotifier unauthorizedNotifier,
  }) : super(const SessionLoading()) {
    on<SessionStarted>(_onStarted);
    on<SessionSignedIn>(_onSignedIn);
    on<SessionSignedOut>(_onSignedOut);
    on<SessionExpired>(_onExpired);
    _subscription = unauthorizedNotifier.onUnauthorized.listen((_) {
      add(const SessionExpired());
    });
  }

  final AuthRepository authRepository;
  final ProfileApi profileApi;
  late final StreamSubscription<void> _subscription;

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    String? token;
    try {
      token = await authRepository.readToken();
    } on Object {
      emit(
        const SessionUnauthenticated(
          message: 'Saved login could not be read. Continuing as a guest.',
        ),
      );
      return;
    }
    if (token == null || token.isEmpty) {
      emit(const SessionUnauthenticated());
      return;
    }
    try {
      final user = await profileApi.me();
      emit(SessionAuthenticated(user: user, signedInNow: false));
    } on AppFailure catch (failure) {
      if (failure.kind == AppFailureKind.unauthorized) {
        emit(const SessionUnauthenticated());
        return;
      }
      emit(
        SessionAuthenticated(
          user: null,
          signedInNow: false,
          message: failure.message,
        ),
      );
    }
  }

  void _onSignedIn(SessionSignedIn event, Emitter<SessionState> emit) {
    emit(SessionAuthenticated(user: event.user, signedInNow: true));
  }

  Future<void> _onSignedOut(
    SessionSignedOut event,
    Emitter<SessionState> emit,
  ) async {
    try {
      await authRepository.clearSession();
    } on Object {
      emit(const SessionUnauthenticated(signedOut: true));
      return;
    }
    emit(const SessionUnauthenticated(signedOut: true));
  }

  void _onExpired(SessionExpired event, Emitter<SessionState> emit) {
    emit(const SessionUnauthenticated());
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
