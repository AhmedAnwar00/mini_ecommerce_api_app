import 'package:mini_ecommerce_app_prompt/features/auth/model/user.dart';

abstract class ProfileApi {
  Future<User> me();
}
