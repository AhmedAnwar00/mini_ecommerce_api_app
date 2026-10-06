import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/key_value_store.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/model/cart.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/model/cart_line.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/checkout_api.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/coupon_api.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/calculate_checkout.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/checkout_policy.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/coupon.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/money.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/model/order.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/viewmodel/checkout_bloc.dart';

void main() {
  const policy = CheckoutPolicy(
    minimumOrder: Money.zero,
    vatBasisPoints: 0,
    flatShipping: Money.zero,
    freeShippingThreshold: Money.zero,
  );
  const mug = CartLine(
    productId: 'p1',
    name: 'Mug',
    priceMinor: 10000,
    quantity: 1,
  );

  test('an unknown coupon is omitted from the quote', () async {
    final repository = CartRepository(_MemoryStore());
    await repository.write(
      const Cart(lines: [mug], couponCode: 'NOPE'),
      userId: 'u1',
    );
    final bloc = CheckoutBloc(
      cartRepository: repository,
      couponApi: _RejectingCouponApi(),
      checkoutApi: _UnusedCheckoutApi(),
      calculateCheckout: const CalculateCheckout(),
      policy: policy,
      ownerId: 'u1',
      membershipBasisPoints: 0,
    );

    bloc.add(const CheckoutRequested());
    final ready = await bloc.stream.firstWhere(
      (state) => state is CheckoutReady,
    );

    expect(ready, isA<CheckoutReady>());
    final draft = (ready as CheckoutReady).draft;
    expect(draft.quote.couponDiscount, Money.zero);
    expect(draft.appliedCouponCode, isNull);
    expect(draft.couponMessage, 'Coupon is not valid.');

    await bloc.close();
  });

  test('a placed order clears only that user cart', () async {
    final repository = CartRepository(_MemoryStore());
    await repository.write(const Cart(lines: [mug]), userId: 'u1');
    await repository.write(const Cart(lines: [mug]), userId: 'u2');
    final bloc = CheckoutBloc(
      cartRepository: repository,
      couponApi: _UnusedCouponApi(),
      checkoutApi: _FixedCheckoutApi(),
      calculateCheckout: const CalculateCheckout(),
      policy: policy,
      ownerId: 'u1',
      membershipBasisPoints: 1000,
    );

    bloc.add(const CheckoutRequested());
    final ready = await bloc.stream.firstWhere(
      (state) => state is CheckoutReady,
    );
    expect(
      (ready as CheckoutReady).draft.quote.membershipDiscount,
      const Money(1000),
    );

    bloc.add(const CheckoutSubmitted());
    final success = await bloc.stream.firstWhere(
      (state) => state is CheckoutSuccess,
    );

    expect(success, isA<CheckoutSuccess>());
    expect((await repository.read(userId: 'u1')).lines, isEmpty);
    final otherCart = await repository.read(userId: 'u2');
    expect(otherCart.lines.single.productId, mug.productId);
    expect(otherCart.lines.single.quantity, mug.quantity);

    await bloc.close();
  });
}

class _MemoryStore implements KeyValueStore {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

class _RejectingCouponApi implements CouponApi {
  @override
  Future<Coupon> validate(String code) {
    throw const AppFailure(AppFailureKind.validation, 'Coupon is not valid.');
  }
}

class _UnusedCouponApi implements CouponApi {
  @override
  Future<Coupon> validate(String code) {
    throw UnimplementedError();
  }
}

class _FixedCheckoutApi implements CheckoutApi {
  @override
  Future<Order> placeOrder({
    required List<CartLine> lines,
    required String? couponCode,
  }) async {
    return const Order(id: 'order-1', totalMinor: 9000);
  }
}

class _UnusedCheckoutApi implements CheckoutApi {
  @override
  Future<Order> placeOrder({
    required List<CartLine> lines,
    required String? couponCode,
  }) {
    throw UnimplementedError();
  }
}
