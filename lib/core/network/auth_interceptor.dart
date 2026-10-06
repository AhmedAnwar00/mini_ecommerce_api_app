import 'package:dio/dio.dart';

import 'package:mini_ecommerce_app_prompt/core/network/dio_failure_mapper.dart';
import 'package:mini_ecommerce_app_prompt/core/network/unauthorized_notifier.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/token_storage.dart';
import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens, this._unauthorized);

  final TokenStorage _tokens;
  final UnauthorizedNotifier _unauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokens.read();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } on Object {
      return handler.next(options);
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final failure = mapDioException(err);
    final isLogin = err.requestOptions.path.endsWith('/auth/login');
    if (failure.kind == AppFailureKind.unauthorized && !isLogin) {
      await _clearToken();
      _unauthorized.notify();
    }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: failure,
        message: failure.message,
      ),
    );
  }

  Future<void> _clearToken() async {
    try {
      await _tokens.clear();
    } on Object catch (error) {
      if (error is AppFailure) return;
    }
  }
}
