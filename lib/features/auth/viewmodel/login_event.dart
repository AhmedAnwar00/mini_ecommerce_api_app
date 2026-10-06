import 'package:mini_ecommerce_app_prompt/features/auth/model/login_request.dart';

sealed class LoginEvent {
  const LoginEvent();
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted(this.request);

  final LoginRequest request;
}
