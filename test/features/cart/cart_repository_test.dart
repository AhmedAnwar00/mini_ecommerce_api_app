import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app_prompt/core/storage/key_value_store.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/model/cart.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/model/cart_line.dart';

void main() {
  test(
    'merges guest quantities into the user cart and clears the guest cart',
    () async {
      final store = InMemoryKeyValueStore();
      final repository = CartRepository(store);
      const guestLine = CartLine(
        productId: 'p1',
        name: 'Mug',
        priceMinor: 1000,
        quantity: 2,
      );
      const userLine = CartLine(
        productId: 'p1',
        name: 'Mug',
        priceMinor: 900,
        quantity: 1,
      );
      await repository.write(
        const Cart(lines: [guestLine], couponCode: 'SAVE'),
      );
      await repository.write(const Cart(lines: [userLine]), userId: 'u1');

      final merged = await repository.mergeGuestIntoUser('u1');

      expect(merged.lines.single.quantity, 3);
      expect(merged.lines.single.priceMinor, 900);
      expect(merged.couponCode, 'SAVE');
      expect((await repository.read()).lines, isEmpty);
      expect((await repository.read(userId: 'u1')).lines.single.quantity, 3);
    },
  );

  test('drops a cart that cannot be decoded', () async {
    final store = InMemoryKeyValueStore();
    final repository = CartRepository(store);
    await store.write(CartRepository.guestKey, '{not json');

    final cart = await repository.read();

    expect(cart.lines, isEmpty);
    expect(await store.read(CartRepository.guestKey), isNull);
  });
}

class InMemoryKeyValueStore implements KeyValueStore {
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
