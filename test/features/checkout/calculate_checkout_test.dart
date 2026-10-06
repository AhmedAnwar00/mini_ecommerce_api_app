import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app_prompt/features/checkout/domain/calculate_checkout.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/checkout_line.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/checkout_policy.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/coupon.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/money.dart';

void main() {
  const calculate = CalculateCheckout();

  CheckoutPolicy policy({
    int minimum = 0,
    int vat = 0,
    int shipping = 0,
    int freeShippingAt = 0,
  }) {
    return CheckoutPolicy(
      minimumOrder: Money(minimum),
      vatBasisPoints: vat,
      flatShipping: Money(shipping),
      freeShippingThreshold: Money(freeShippingAt),
    );
  }

  test('sums two lines', () {
    final quote = calculate(
      lines: const [
        CheckoutLine(price: Money(2500), quantity: 2),
        CheckoutLine(price: Money(1000), quantity: 1),
      ],
      policy: policy(),
      membershipBasisPoints: 0,
    );

    expect(quote.merchandise, const Money(6000));
    expect(quote.total, const Money(6000));
    expect(quote.canPlaceOrder, isTrue);
  });

  test('blocks an order one minor unit below the minimum', () {
    final quote = calculate(
      lines: const [CheckoutLine(price: Money(4999), quantity: 1)],
      policy: policy(minimum: 5000),
      membershipBasisPoints: 0,
    );

    expect(quote.merchandise, const Money(4999));
    expect(quote.meetsMinimum, isFalse);
    expect(quote.canPlaceOrder, isFalse);
  });

  test('allows an order equal to the minimum', () {
    final quote = calculate(
      lines: const [CheckoutLine(price: Money(5000), quantity: 1)],
      policy: policy(minimum: 5000),
      membershipBasisPoints: 0,
    );

    expect(quote.meetsMinimum, isTrue);
    expect(quote.canPlaceOrder, isTrue);
  });

  test('applies an exact percent coupon', () {
    final quote = calculate(
      lines: const [CheckoutLine(price: Money(10000), quantity: 1)],
      policy: policy(),
      coupon: const PercentCoupon(1000),
      membershipBasisPoints: 0,
    );

    expect(quote.couponDiscount, const Money(1000));
    expect(quote.taxable, const Money(9000));
  });

  test('rounds a percent coupon half up', () {
    final quote = calculate(
      lines: const [CheckoutLine(price: Money(3333), quantity: 1)],
      policy: policy(),
      coupon: const PercentCoupon(1000),
      membershipBasisPoints: 0,
    );

    expect(quote.couponDiscount, const Money(333));
  });

  test('clamps a fixed coupon to the merchandise', () {
    final quote = calculate(
      lines: const [CheckoutLine(price: Money(1000), quantity: 1)],
      policy: policy(vat: 1400, shipping: 2500, freeShippingAt: 0),
      coupon: const FixedCoupon(Money(5000)),
      membershipBasisPoints: 0,
    );

    expect(quote.couponDiscount, const Money(1000));
    expect(quote.taxable, Money.zero);
    expect(quote.vat, Money.zero);
  });

  test('applies membership to the post-coupon amount', () {
    final quote = calculate(
      lines: const [CheckoutLine(price: Money(10000), quantity: 1)],
      policy: policy(),
      coupon: const PercentCoupon(1000),
      membershipBasisPoints: 1000,
    );

    expect(quote.couponDiscount, const Money(1000));
    expect(quote.membershipDiscount, const Money(900));
    expect(quote.taxable, const Money(8100));
  });

  test('leaves the post-coupon amount unchanged when membership is zero', () {
    final quote = calculate(
      lines: const [CheckoutLine(price: Money(10000), quantity: 1)],
      policy: policy(),
      coupon: const PercentCoupon(1000),
      membershipBasisPoints: 0,
    );

    expect(quote.membershipDiscount, Money.zero);
    expect(quote.taxable, const Money(9000));
  });

  test('keeps free shipping when a coupon drops goods below the threshold', () {
    final quote = calculate(
      lines: const [CheckoutLine(price: Money(20000), quantity: 1)],
      policy: policy(shipping: 1500, freeShippingAt: 20000),
      coupon: const PercentCoupon(5000),
      membershipBasisPoints: 0,
    );

    expect(quote.taxable, const Money(10000));
    expect(quote.shipping, Money.zero);
  });

  test('charges shipping one minor unit below the threshold', () {
    final quote = calculate(
      lines: const [CheckoutLine(price: Money(19999), quantity: 1)],
      policy: policy(shipping: 1500, freeShippingAt: 20000),
      membershipBasisPoints: 0,
    );

    expect(quote.shipping, const Money(1500));
    expect(quote.total, const Money(21499));
  });

  test('rounds VAT half up', () {
    final quote = calculate(
      lines: const [CheckoutLine(price: Money(10), quantity: 1)],
      policy: policy(vat: 1500),
      membershipBasisPoints: 0,
    );

    expect(quote.vat, const Money(2));
    expect(quote.total, const Money(12));
  });

  test('returns a zero quote for an empty cart', () {
    final quote = calculate(
      lines: const [],
      policy: policy(
        vat: 1400,
        shipping: 1500,
        freeShippingAt: 100,
        minimum: 5000,
      ),
      membershipBasisPoints: 1000,
    );

    expect(quote.total, Money.zero);
    expect(quote.shipping, Money.zero);
    expect(quote.canPlaceOrder, isFalse);
  });

  test('treats a missing coupon as no discount', () {
    final quote = calculate(
      lines: const [CheckoutLine(price: Money(10000), quantity: 1)],
      policy: policy(),
      membershipBasisPoints: 0,
    );

    expect(quote.couponDiscount, Money.zero);
  });

  test('rejects a negative price', () {
    expect(
      () => calculate(
        lines: const [CheckoutLine(price: Money(-1), quantity: 1)],
        policy: policy(),
        membershipBasisPoints: 0,
      ),
      throwsArgumentError,
    );
  });
}
