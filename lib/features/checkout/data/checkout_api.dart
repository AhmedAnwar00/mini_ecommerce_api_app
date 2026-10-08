import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_line.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/order.dart';

abstract class CheckoutApi {
  Future<Order> placeOrder({
    required List<CartLine> lines,
    required String? couponCode,
  });
}
