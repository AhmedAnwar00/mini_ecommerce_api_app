import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/core/network/unauthorized_notifier.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/model/user.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_event.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_state.dart';
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
import 'package:mini_ecommerce_app_prompt/features/profile/data/profile_api.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/key_value_store.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/token_storage.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_api.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/model/auth_session.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/model/login_request.dart';

void main() {
  test('an unknown coupon is omitted from the quote', () async {
    final store = _MemoryStore();
    final repository = CartRepository(store);
    const user = User(
      id: 'u1',
      name: 'Ada',
      email: 'ada@shop.test',
      membershipBasisPoints: 0,
    );
    final session = SessionBloc(
      authRepository: AuthRepository(_UnusedAuthApi(), _MemoryTokens()),
      profileApi: _UnusedProfileApi(),
      unauthorizedNotifier: UnauthorizedNotifier(),
    );
    session.add(const SessionSignedIn(user));
    await session.stream.firstWhere((state) => state is SessionAuthenticated);
    await repository.write(
      const Cart(
        lines: [
          CartLine(
            productId: 'p1',
            name: 'Mug',
            priceMinor: 10000,
            quantity: 1,
          ),
        ],
        couponCode: 'NOPE',
      ),
      userId: user.id,
    );
    final bloc = CheckoutBloc(
      cartRepository: repository,
      couponApi: _RejectingCouponApi(),
      checkoutApi: _UnusedCheckoutApi(),
      sessionBloc: session,
      calculateCheckout: const CalculateCheckout(),
      policy: const CheckoutPolicy(
        minimumOrder: Money.zero,
        vatBasisPoints: 0,
        flatShipping: Money.zero,
        freeShippingThreshold: Money.zero,
      ),
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
    await session.close();
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

class _MemoryTokens implements TokenStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String token) async {}
}

class _UnusedAuthApi implements AuthApi {
  @override
  Future<AuthSession> login(LoginRequest request) {
    throw UnimplementedError();
  }
}

class _UnusedProfileApi implements ProfileApi {
  @override
  Future<User> me() {
    throw UnimplementedError();
  }
}

class _RejectingCouponApi implements CouponApi {
  @override
  Future<Coupon> validate(String code) {
    throw const AppFailure(AppFailureKind.validation, 'Coupon is not valid.');
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
