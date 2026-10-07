import 'package:flutter/material.dart';

import 'package:mini_ecommerce_app_prompt/features/cart/data/cart.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/view/widgets/cart_checkout_bar.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/view/widgets/cart_coupon_field.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/view/widgets/cart_line_tile.dart';

class CartReadyBody extends StatelessWidget {
  const CartReadyBody({super.key, required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final line in cart.lines) ...[
                CartLineTile(line: line),
                const SizedBox(height: 8),
              ],
              CartCouponField(
                key: ValueKey(cart.couponCode),
                couponCode: cart.couponCode,
              ),
            ],
          ),
        ),
        const CartCheckoutBar(),
      ],
    );
  }
}
