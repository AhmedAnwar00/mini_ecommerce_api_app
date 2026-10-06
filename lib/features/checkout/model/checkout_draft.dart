import 'package:mini_ecommerce_app_prompt/features/cart/model/cart.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/checkout_quote.dart';

class CheckoutDraft {
  const CheckoutDraft({
    required this.cart,
    required this.quote,
    this.appliedCouponCode,
    this.couponMessage,
  });

  final Cart cart;
  final CheckoutQuote quote;
  final String? appliedCouponCode;
  final String? couponMessage;
}
