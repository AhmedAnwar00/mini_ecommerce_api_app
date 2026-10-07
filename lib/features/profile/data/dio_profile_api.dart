import 'package:dio/dio.dart';

import 'package:mini_ecommerce_app_prompt/core/network/dio_client.dart';
import 'package:mini_ecommerce_app_prompt/core/network/json_body.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/user.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/data/profile_api.dart';

class DioProfileApi implements ProfileApi {
  DioProfileApi(this._dio);

  final Dio _dio;

  @override
  Future<User> me() {
    return runRequest(() async {
      final response = await _dio.get<Object?>('/me');
      return User.fromJson(requireJsonMap(response.data));
    });
  }
}
