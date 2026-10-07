import 'dart:async';
import 'dart:convert';

import 'package:mini_ecommerce_app_prompt/core/storage/key_value_store.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart.dart';

class CartRepository {
  CartRepository(this._store);

  final KeyValueStore _store;
  final _updates = StreamController<void>.broadcast();

  Stream<void> get updates => _updates.stream;

  static const guestKey = 'cart_guest';

  static String userKey(String userId) => 'cart_user_$userId';

  Future<Cart> read({String? userId}) async {
    final key = _key(userId);
    final raw = await _store.read(key);
    if (raw == null || raw.isEmpty) return Cart.empty;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) throw const FormatException('Cart');
      return Cart.fromJson(Map<String, dynamic>.from(decoded));
    } on FormatException {
      await _store.delete(key);
      return Cart.empty;
    }
  }

  Future<void> write(Cart cart, {String? userId}) async {
    final key = _key(userId);
    final coupon = cart.couponCode?.trim();
    final stored = Cart(
      lines: cart.lines,
      couponCode: coupon == null || coupon.isEmpty ? null : coupon,
    );
    if (stored.lines.isEmpty && stored.couponCode == null) {
      await _store.delete(key);
      _publish();
      return;
    }
    await _store.write(key, jsonEncode(stored.toJson()));
    _publish();
  }

  Future<Cart> mergeGuestIntoUser(String userId) async {
    final guest = await read();
    final user = await read(userId: userId);
    final merged = _merge(user, guest);
    await write(merged, userId: userId);
    await write(Cart.empty);
    return merged;
  }

  Cart _merge(Cart user, Cart guest) {
    final lines = [...user.lines];
    for (final guestLine in guest.lines) {
      final index = lines.indexWhere(
        (line) => line.productId == guestLine.productId,
      );
      if (index >= 0) {
        lines[index] = lines[index].copyWith(
          quantity: lines[index].quantity + guestLine.quantity,
        );
      } else {
        lines.add(guestLine);
      }
    }
    final coupon = user.couponCode ?? guest.couponCode;
    return Cart(lines: lines, couponCode: coupon);
  }

  String _key(String? userId) => userId == null ? guestKey : userKey(userId);

  void _publish() {
    if (_updates.isClosed) return;
    _updates.add(null);
  }
}
