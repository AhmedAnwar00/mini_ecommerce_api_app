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

  group('merchandise total', () {
    test('sums price times quantity across lines when no coupon is applied', () {
      final quote = calculate(
        lines: const [
          CheckoutLine(price: Money(2500), quantity: 2),
          CheckoutLine(price: Money(1000), quantity: 1),
        ],
        policy: policy(),
        membershipBasisPoints: 0,
      );

      expect(quote.merchandise, const Money(6000));
      expect(quote.couponDiscount, Money.zero);
      expect(quote.membershipDiscount, Money.zero);
      expect(quote.taxable, const Money(6000));
      expect(quote.vat, Money.zero);
      expect(quote.shipping, Money.zero);
      expect(quote.total, const Money(6000));
    });

    test('multiplies a quantity past the 53-bit float range in minor units', () {
      final quote = calculate(
        lines: const [
          CheckoutLine(price: Money(1), quantity: 9007199254740993),
          CheckoutLine(price: Money(2500), quantity: 2),
        ],
        policy: policy(),
        membershipBasisPoints: 0,
      );

      expect(quote.merchandise, const Money(9007199254745993));
      expect(quote.total, const Money(9007199254745993));
    });
  });

  group('minimum order and canPlaceOrder', () {
    test('blocks an order one minor unit below the minimum', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(4999), quantity: 1)],
        policy: policy(minimum: 5000),
        membershipBasisPoints: 0,
      );

      expect(quote.merchandise, const Money(4999));
      expect(quote.minimumOrder, const Money(5000));
      expect(quote.meetsMinimum, isFalse);
      expect(quote.canPlaceOrder, isFalse);
      expect(quote.canPlaceOrder, quote.meetsMinimum);
    });

    test('allows an order equal to the minimum', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(5000), quantity: 1)],
        policy: policy(minimum: 5000),
        membershipBasisPoints: 0,
      );

      expect(quote.meetsMinimum, isTrue);
      expect(quote.canPlaceOrder, isTrue);
      expect(quote.canPlaceOrder, quote.meetsMinimum);
    });

    test('keeps canPlaceOrder when a coupon drops the taxable amount below the minimum', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(5000), quantity: 1)],
        policy: policy(minimum: 5000),
        coupon: const FixedCoupon(Money(4000)),
        membershipBasisPoints: 0,
      );

      expect(quote.merchandise, const Money(5000));
      expect(quote.taxable, const Money(1000));
      expect(quote.meetsMinimum, isTrue);
      expect(quote.canPlaceOrder, isTrue);
    });

    test('returns a zero quote that cannot be placed for an empty cart', () {
      final quote = calculate(
        lines: const [],
        policy: policy(
          minimum: 5000,
          vat: 1400,
          shipping: 1500,
          freeShippingAt: 100,
        ),
        coupon: const PercentCoupon(1000),
        membershipBasisPoints: 1000,
      );

      expect(quote.merchandise, Money.zero);
      expect(quote.total, Money.zero);
      expect(quote.shipping, Money.zero);
      expect(quote.meetsMinimum, isFalse);
      expect(quote.canPlaceOrder, isFalse);
    });
  });

  group('coupon', () {
    test('applies a valid percentage coupon to the merchandise total', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(10000), quantity: 1)],
        policy: policy(),
        coupon: const PercentCoupon(1000),
        membershipBasisPoints: 0,
      );

      expect(quote.couponDiscount, const Money(1000));
      expect(quote.taxable, const Money(9000));
      expect(quote.total, const Money(9000));
    });

    test('applies a valid fixed-amount coupon in minor units', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(10000), quantity: 1)],
        policy: policy(),
        coupon: const FixedCoupon(Money(2500)),
        membershipBasisPoints: 0,
      );

      expect(quote.couponDiscount, const Money(2500));
      expect(quote.taxable, const Money(7500));
      expect(quote.total, const Money(7500));
    });

    test('treats a missing coupon as no discount', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(10000), quantity: 1)],
        policy: policy(vat: 1400, shipping: 1500, freeShippingAt: 20000),
        membershipBasisPoints: 0,
      );

      expect(quote.couponDiscount, Money.zero);
      expect(quote.taxable, const Money(10000));
      expect(quote.vat, const Money(1400));
      expect(quote.shipping, const Money(1500));
      expect(quote.total, const Money(12900));
    });

    test('ignores a non-positive percentage coupon', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(10000), quantity: 1)],
        policy: policy(),
        coupon: const PercentCoupon(0),
        membershipBasisPoints: 0,
      );

      expect(quote.couponDiscount, Money.zero);
      expect(quote.taxable, const Money(10000));
    });

    test('ignores a non-positive fixed coupon', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(10000), quantity: 1)],
        policy: policy(),
        coupon: const FixedCoupon(Money(-500)),
        membershipBasisPoints: 0,
      );

      expect(quote.couponDiscount, Money.zero);
      expect(quote.total, const Money(10000));
    });

    test('clamps a fixed coupon to the merchandise total', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(1000), quantity: 1)],
        policy: policy(vat: 1400, shipping: 2500, freeShippingAt: 5000),
        coupon: const FixedCoupon(Money(5000)),
        membershipBasisPoints: 0,
      );

      expect(quote.couponDiscount, const Money(1000));
      expect(quote.taxable, Money.zero);
      expect(quote.vat, Money.zero);
      expect(quote.shipping, const Money(2500));
      expect(quote.total, const Money(2500));
    });

    test('caps a percentage coupon above 100 percent at the merchandise total', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(8000), quantity: 1)],
        policy: policy(),
        coupon: const PercentCoupon(15000),
        membershipBasisPoints: 0,
      );

      expect(quote.couponDiscount, const Money(8000));
      expect(quote.taxable, Money.zero);
      expect(quote.total, Money.zero);
    });
  });

  group('membership discount', () {
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

    test('applies membership alone when no coupon is present', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(10000), quantity: 1)],
        policy: policy(),
        membershipBasisPoints: 1000,
      );

      expect(quote.couponDiscount, Money.zero);
      expect(quote.membershipDiscount, const Money(1000));
      expect(quote.taxable, const Money(9000));
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
  });

  group('rounding', () {
    test('rounds a percent coupon half up', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(3333), quantity: 1)],
        policy: policy(),
        coupon: const PercentCoupon(1000),
        membershipBasisPoints: 0,
      );

      expect(quote.couponDiscount, const Money(333));
      expect(quote.taxable, const Money(3000));
    });

    test('rounds an exact half minor unit up', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(1), quantity: 1)],
        policy: policy(),
        coupon: const PercentCoupon(5000),
        membershipBasisPoints: 0,
      );

      expect(quote.couponDiscount, const Money(1));
      expect(quote.taxable, Money.zero);
    });

    test('leaves a fraction just below one half as zero', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(1), quantity: 1)],
        policy: policy(),
        coupon: const PercentCoupon(4999),
        membershipBasisPoints: 0,
      );

      expect(quote.couponDiscount, Money.zero);
      expect(quote.total, const Money(1));
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

    test('rounds a VAT fraction above one half up to the next minor unit', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(4), quantity: 1)],
        policy: policy(vat: 1500),
        membershipBasisPoints: 0,
      );

      expect(quote.vat, const Money(1));
      expect(quote.total, const Money(5));
    });
  });

  group('shipping', () {
    test('waives shipping exactly at the free-shipping threshold', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(20000), quantity: 1)],
        policy: policy(shipping: 1500, freeShippingAt: 20000),
        membershipBasisPoints: 0,
      );

      expect(quote.merchandise, const Money(20000));
      expect(quote.shipping, Money.zero);
      expect(quote.total, const Money(20000));
    });

    test('charges flat shipping one minor unit below the threshold', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(19999), quantity: 1)],
        policy: policy(shipping: 1500, freeShippingAt: 20000),
        membershipBasisPoints: 0,
      );

      expect(quote.shipping, const Money(1500));
      expect(quote.total, const Money(21499));
    });

    test('keeps free shipping when a coupon drops goods below the threshold', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(20000), quantity: 1)],
        policy: policy(shipping: 1500, freeShippingAt: 20000),
        coupon: const PercentCoupon(5000),
        membershipBasisPoints: 0,
      );

      expect(quote.merchandise, const Money(20000));
      expect(quote.taxable, const Money(10000));
      expect(quote.shipping, Money.zero);
      expect(quote.total, const Money(10000));
    });

    test('treats a negative flat shipping amount as zero', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(1000), quantity: 1)],
        policy: policy(shipping: -500, freeShippingAt: 100000),
        membershipBasisPoints: 0,
      );

      expect(quote.shipping, Money.zero);
      expect(quote.total, const Money(1000));
    });
  });

  group('combined quote', () {
    test('applies coupon, then membership, then VAT, then shipping', () {
      final quote = calculate(
        lines: const [CheckoutLine(price: Money(8000), quantity: 2)],
        policy: policy(
          minimum: 5000,
          vat: 1400,
          shipping: 1500,
          freeShippingAt: 20000,
        ),
        coupon: const FixedCoupon(Money(3000)),
        membershipBasisPoints: 1000,
      );

      expect(quote.merchandise, const Money(16000));
      expect(quote.couponDiscount, const Money(3000));
      expect(quote.membershipDiscount, const Money(1300));
      expect(quote.taxable, const Money(11700));
      expect(quote.vat, const Money(1638));
      expect(quote.shipping, const Money(1500));
      expect(quote.total, const Money(14838));
      expect(quote.minimumOrder, const Money(5000));
      expect(quote.meetsMinimum, isTrue);
      expect(quote.canPlaceOrder, isTrue);
    });
  });

  group('invalid lines', () {
    test('rejects a line with quantity zero', () {
      expect(
        () => calculate(
          lines: const [
            CheckoutLine(price: Money(2500), quantity: 1),
            CheckoutLine(price: Money(1000), quantity: 0),
          ],
          policy: policy(minimum: 5000),
          membershipBasisPoints: 0,
        ),
        throwsArgumentError,
      );
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
  });
}
