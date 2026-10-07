import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app_prompt/core/network/unauthorized_notifier.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/key_value_store.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/token_storage.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_api.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_session.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/login_request.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/user.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_line.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/viewmodel/cart_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/product.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/data/profile_api.dart';

const _user = User(
  id: 'u1',
  name: 'Ada',
  email: 'ada@example.com',
  membershipBasisPoints: 500,
);

const _product = Product(
  id: 'p1',
  name: 'Mug',
  description: 'Ceramic',
  priceMinor: 1000,
);

const _line = CartLine(
  productId: 'p1',
  name: 'Mug',
  priceMinor: 1000,
  quantity: 1,
);

void main() {
  test('starts in loading', () async {
    final harness = await _Harness.open();

    expect(harness.cubit.state, isA<CartLoading>());
    await harness.close();
  });

  test('stays loading while the session is loading', () async {
    final harness = await _Harness.open();

    await harness.cubit.start();

    expect(harness.cubit.state, isA<CartLoading>());
    await harness.close();
  });

  test('loads an empty guest cart', () async {
    final harness = await _Harness.open(signedOut: true);

    final state = harness.cubit.state as CartEmpty;
    expect(state.cart.lines, isEmpty);
    expect(state.cart.couponCode, isNull);
    await harness.close();
  });

  test('loads a saved guest cart', () async {
    final store = _MemoryStore();
    final repository = CartRepository(store);
    await repository.write(const Cart(lines: [_line], couponCode: 'SAVE'));
    final harness = await _Harness.open(
      repository: repository,
      signedOut: true,
    );

    final state = harness.cubit.state as CartReady;
    expect(state.cart.lines.single.quantity, 1);
    expect(state.cart.couponCode, 'SAVE');
    await harness.close();
  });

  test('adds a product and stacks quantity', () async {
    final harness = await _Harness.open(signedOut: true);

    await harness.cubit.addProduct(_product);
    await harness.cubit.addProduct(_product);

    final state = harness.cubit.state as CartReady;
    expect(state.cart.lines.single.productId, 'p1');
    expect(state.cart.lines.single.quantity, 2);
    await harness.close();
  });

  test('changes quantity and removes a line at zero', () async {
    final harness = await _Harness.open(signedOut: true);
    await harness.cubit.addProduct(_product);

    await harness.cubit.increaseQuantity('p1');
    expect((harness.cubit.state as CartReady).cart.lines.single.quantity, 2);

    await harness.cubit.decreaseQuantity('missing');
    expect((harness.cubit.state as CartReady).cart.lines.single.quantity, 2);

    await harness.cubit.decreaseQuantity('p1');
    await harness.cubit.decreaseQuantity('p1');

    expect(harness.cubit.state, isA<CartEmpty>());
    await harness.close();
  });

  test('removes a line', () async {
    final harness = await _Harness.open(signedOut: true);
    await harness.cubit.addProduct(_product);

    await harness.cubit.removeLine('p1');

    expect(harness.cubit.state, isA<CartEmpty>());
    await harness.close();
  });

  test('saves a trimmed coupon and clears a blank one', () async {
    final harness = await _Harness.open(signedOut: true);

    await harness.cubit.saveCoupon('  SAVE  ');
    expect((harness.cubit.state as CartEmpty).cart.couponCode, 'SAVE');

    await harness.cubit.saveCoupon('   ');
    expect((harness.cubit.state as CartEmpty).cart.couponCode, isNull);
    await harness.close();
  });

  test('reloads when the repository publishes an update', () async {
    final repository = CartRepository(_MemoryStore());
    final harness = await _Harness.open(
      repository: repository,
      signedOut: true,
    );
    final reloaded = harness.cubit.stream.firstWhere(
      (state) => state is CartReady,
    );

    await repository.write(const Cart(lines: [_line]));
    final state = await reloaded as CartReady;

    expect(state.cart.lines.single.productId, 'p1');
    await harness.close();
  });

  test('reports a read failure', () async {
    final harness = await _Harness.open(
      repository: CartRepository(_ThrowingStore()),
      signedOut: true,
    );

    expect(
      (harness.cubit.state as CartFailure).message,
      'The cart could not be read.',
    );
    await harness.close();
  });

  test('merges the guest cart when the user signs in', () async {
    final repository = CartRepository(_MemoryStore());
    await repository.write(const Cart(lines: [_line], couponCode: 'SAVE'));
    final harness = await _Harness.open(
      repository: repository,
      signedOut: true,
    );
    final merged = harness.cubit.stream.firstWhere((state) => state is CartReady);

    harness.session.signIn(_user);
    final state = await merged as CartReady;

    expect(state.cart.lines.single.quantity, 1);
    expect(state.cart.couponCode, 'SAVE');
    expect((await repository.read()).lines, isEmpty);
    expect((await repository.read(userId: 'u1')).lines.single.quantity, 1);
    await harness.close();
  });

  test('reports a save failure when merge fails', () async {
    final harness = await _Harness.open(
      repository: _MergeFailRepository(_MemoryStore()),
      signedOut: true,
    );
    final failed = harness.cubit.stream.firstWhere(
      (state) => state is CartFailure,
    );

    harness.session.signIn(_user);

    expect(
      ((await failed) as CartFailure).message,
      'The cart could not be saved.',
    );
    await harness.close();
  });
}

class _Harness {
  _Harness(this.session, this.cubit, this.notifier);

  final SessionCubit session;
  final CartCubit cubit;
  final UnauthorizedNotifier notifier;

  static Future<_Harness> open({
    CartRepository? repository,
    bool signedOut = false,
  }) async {
    final notifier = UnauthorizedNotifier();
    final session = SessionCubit(
      authRepository: AuthRepository(_UnusedAuthApi(), _MemoryTokens()),
      profileApi: _UnusedProfileApi(),
      unauthorizedNotifier: notifier,
    );
    final cubit = CartCubit(
      repository: repository ?? CartRepository(_MemoryStore()),
      sessionBloc: session,
    );
    if (signedOut) {
      final loaded = cubit.stream.first;
      session.expire();
      await loaded;
    }
    return _Harness(session, cubit, notifier);
  }

  Future<void> close() async {
    await cubit.close();
    await session.close();
    await notifier.dispose();
  }
}

class _MemoryStore implements KeyValueStore {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

class _ThrowingStore implements KeyValueStore {
  @override
  Future<void> delete(String key) async {}

  @override
  Future<String?> read(String key) async => throw StateError('disk');

  @override
  Future<void> write(String key, String value) async {}
}

class _MergeFailRepository extends CartRepository {
  _MergeFailRepository(super.store);

  @override
  Future<Cart> mergeGuestIntoUser(String userId) async {
    throw StateError('merge');
  }
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
