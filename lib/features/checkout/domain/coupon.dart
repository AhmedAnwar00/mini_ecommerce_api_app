import 'package:mini_ecommerce_app_prompt/features/checkout/domain/money.dart';

sealed class Coupon {
  const Coupon();

  factory Coupon.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 'percent') {
      return PercentCoupon((json['basisPoints'] as num?)?.toInt() ?? 0);
    }
    if (type == 'fixed') {
      return FixedCoupon(Money((json['amountMinor'] as num?)?.toInt() ?? 0));
    }
    throw const FormatException('Unknown coupon');
  }
}

class PercentCoupon extends Coupon {
  const PercentCoupon(this.basisPoints);

  final int basisPoints;
}

class FixedCoupon extends Coupon {
  const FixedCoupon(this.amount);

  final Money amount;
}
