import 'package:mini_ecommerce_app_prompt/features/checkout/domain/coupon.dart';

abstract class CouponApi {
  Future<Coupon> validate(String code);
}
