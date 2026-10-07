import 'package:mini_ecommerce_app_prompt/features/auth/data/user.dart';

abstract class ProfileApi {
  Future<User> me();
}
