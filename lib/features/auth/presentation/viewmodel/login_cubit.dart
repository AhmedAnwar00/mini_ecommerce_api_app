import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/login_request.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginIdle());

  final AuthRepository _repository;

  Future<void> submit(LoginRequest request) async {
    final email = request.email.trim();
    if (email.isEmpty || request.password.isEmpty) {
      emit(const LoginFailure('Enter your email and password.'));
      return;
    }
    emit(const LoginSubmitting());
    try {
      final user = await _repository.login(request);
      emit(LoginSuccess(user));
    } on AppFailure catch (failure) {
      emit(LoginFailure(failure.message));
    }
  }
}
