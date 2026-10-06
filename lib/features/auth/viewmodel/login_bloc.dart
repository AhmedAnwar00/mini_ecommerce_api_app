import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/login_event.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._repository) : super(const LoginIdle()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final AuthRepository _repository;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final email = event.request.email.trim();
    if (email.isEmpty || event.request.password.isEmpty) {
      emit(const LoginFailure('Enter your email and password.'));
      return;
    }
    emit(const LoginSubmitting());
    try {
      final user = await _repository.login(event.request);
      emit(LoginSuccess(user));
    } on AppFailure catch (failure) {
      emit(LoginFailure(failure.message));
    }
  }
}
