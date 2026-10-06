import 'package:mini_ecommerce_app_prompt/features/checkout/domain/checkout_line.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/checkout_policy.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/checkout_quote.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/coupon.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/money.dart';

class CalculateCheckout {
  const CalculateCheckout();

  CheckoutQuote call({
    required List<CheckoutLine> lines,
    required CheckoutPolicy policy,
    Coupon? coupon,
    required int membershipBasisPoints,
  }) {
    for (final line in lines) {
      if (line.price.minor < 0 || line.quantity <= 0) {
        throw ArgumentError('Invalid checkout line');
      }
    }
    if (lines.isEmpty) return CheckoutQuote.empty;

    var merchandise = 0;
    for (final line in lines) {
      merchandise += line.price.minor * line.quantity;
    }
    final meetsMinimum = merchandise >= policy.minimumOrder.minor;
    final couponDiscount = _couponDiscount(merchandise, coupon);
    final afterCoupon = merchandise - couponDiscount;
    final membershipDiscount = percentOfMinor(
      afterCoupon,
      membershipBasisPoints,
    );
    final taxable = afterCoupon - membershipDiscount;
    final vat = percentOfMinor(taxable, policy.vatBasisPoints);
    final shipping = merchandise >= policy.freeShippingThreshold.minor
        ? 0
        : _nonNegative(policy.flatShipping.minor);
    final total = taxable + vat + shipping;

    return CheckoutQuote(
      merchandise: Money(merchandise),
      couponDiscount: Money(couponDiscount),
      membershipDiscount: Money(membershipDiscount),
      taxable: Money(taxable),
      vat: Money(vat),
      shipping: Money(shipping),
      total: Money(total),
      minimumOrder: policy.minimumOrder,
      meetsMinimum: meetsMinimum,
      canPlaceOrder: meetsMinimum,
    );
  }

  int _couponDiscount(int merchandise, Coupon? coupon) {
    if (coupon == null || merchandise <= 0) return 0;
    final raw = switch (coupon) {
      PercentCoupon(:final basisPoints) => percentOfMinor(
        merchandise,
        basisPoints,
      ),
      FixedCoupon(:final amount) => amount.minor,
    };
    if (raw <= 0) return 0;
    if (raw > merchandise) return merchandise;
    return raw;
  }

  int _nonNegative(int value) => value < 0 ? 0 : value;
}
