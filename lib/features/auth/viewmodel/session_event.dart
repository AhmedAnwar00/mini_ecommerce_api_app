import 'package:mini_ecommerce_app_prompt/features/auth/model/user.dart';

sealed class SessionEvent {
  const SessionEvent();
}

class SessionStarted extends SessionEvent {
  const SessionStarted();
}

class SessionSignedIn extends SessionEvent {
  const SessionSignedIn(this.user);

  final User user;
}

class SessionSignedOut extends SessionEvent {
  const SessionSignedOut();
}

class SessionExpired extends SessionEvent {
  const SessionExpired();
}
