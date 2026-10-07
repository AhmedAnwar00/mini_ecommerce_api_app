import 'package:mini_ecommerce_app_prompt/features/auth/data/user.dart';

sealed class LoginState {
  const LoginState();
}

class LoginIdle extends LoginState {
  const LoginIdle();
}

class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;
}

class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);

  final User user;
}
