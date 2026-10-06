import 'package:mini_ecommerce_app_prompt/features/auth/model/user.dart';

sealed class SessionState {
  const SessionState();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated({this.message});

  final String? message;
}

class SessionAuthenticated extends SessionState {
  const SessionAuthenticated({
    required this.user,
    required this.signedInNow,
    this.message,
  });

  final User? user;
  final bool signedInNow;
  final String? message;
}
