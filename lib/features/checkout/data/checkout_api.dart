import 'package:mini_ecommerce_app_prompt/features/cart/model/cart_line.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/model/order.dart';

abstract class CheckoutApi {
  Future<Order> placeOrder({
    required List<CartLine> lines,
    required String? couponCode,
  });
}
