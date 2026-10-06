import 'package:dio/dio.dart';

import 'package:mini_ecommerce_app_prompt/core/network/dio_client.dart';
import 'package:mini_ecommerce_app_prompt/core/network/json_body.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/coupon_api.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/coupon.dart';

class DioCouponApi implements CouponApi {
  DioCouponApi(this._dio);

  final Dio _dio;

  @override
  Future<Coupon> validate(String code) {
    return runRequest(() async {
      final response = await _dio.post<Object?>(
        '/coupons/validate',
        data: {'code': code},
      );
      return Coupon.fromJson(requireJsonMap(response.data));
    });
  }
}
