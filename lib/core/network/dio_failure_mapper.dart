import 'package:dio/dio.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';

AppFailure mapDioException(DioException exception) {
  final status = exception.response?.statusCode;
  if (status == 401) {
    return const AppFailure(
      AppFailureKind.unauthorized,
      'Your session has expired.',
    );
  }
  if (status == 404) {
    return const AppFailure(AppFailureKind.notFound, 'Not found.');
  }
  if (status == 400 || status == 422) {
    return const AppFailure(
      AppFailureKind.validation,
      'Please check your details and try again.',
    );
  }
  if (exception.type == DioExceptionType.connectionTimeout ||
      exception.type == DioExceptionType.receiveTimeout ||
      exception.type == DioExceptionType.sendTimeout ||
      exception.type == DioExceptionType.connectionError) {
    return const AppFailure(
      AppFailureKind.network,
      'Network error. Check your connection.',
    );
  }
  return const AppFailure(AppFailureKind.unknown, 'Something went wrong.');
}
