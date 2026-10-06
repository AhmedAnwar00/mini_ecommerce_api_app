import 'package:dio/dio.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/core/network/dio_client.dart';
import 'package:mini_ecommerce_app_prompt/core/network/json_body.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_api.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/model/auth_session.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/model/login_request.dart';

class DioAuthApi implements AuthApi {
  DioAuthApi(this._dio);

  final Dio _dio;

  @override
  Future<AuthSession> login(LoginRequest request) async {
    try {
      return await runRequest(() async {
        final response = await _dio.post<Object?>(
          '/auth/login',
          data: request.toJson(),
        );
        return AuthSession.fromJson(requireJsonMap(response.data));
      });
    } on AppFailure catch (failure) {
      if (failure.kind == AppFailureKind.unauthorized) {
        throw const AppFailure(
          AppFailureKind.validation,
          'Incorrect email or password.',
        );
      }
      rethrow;
    }
  }
}
