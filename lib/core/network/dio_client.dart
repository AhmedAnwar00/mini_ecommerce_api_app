import 'package:dio/dio.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/core/network/dio_failure_mapper.dart';
import 'package:mini_ecommerce_app_prompt/core/network/auth_interceptor.dart';

const apiBaseUrl = 'https://api.example.com';

Dio createDio({
  required String baseUrl,
  required AuthInterceptor authInterceptor,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  dio.interceptors.add(authInterceptor);
  return dio;
}

Future<T> runRequest<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on DioException catch (error) {
    final mapped = error.error;
    if (mapped is AppFailure) throw mapped;
    throw mapDioException(error);
  } on FormatException {
    throw const AppFailure(AppFailureKind.unknown, 'Something went wrong.');
  }
}
