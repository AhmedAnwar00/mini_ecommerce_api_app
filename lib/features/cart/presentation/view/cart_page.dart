import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/widgets/empty_view.dart';
import 'package:mini_ecommerce_app_prompt/core/ui/widgets/error_view.dart';
import 'package:mini_ecommerce_app_prompt/core/ui/widgets/loading_view.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/view/widgets/cart_coupon_field.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/view/widgets/cart_ready_body.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/viewmodel/cart_cubit.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return switch (state) {
            CartLoading() => const LoadingView(),
            CartFailure(:final message) => ErrorView(
              message: message,
              onAction: () => context.read<CartCubit>().start(),
            ),
            CartEmpty(:final cart) => Column(
              children: [
                const Expanded(
                  child: EmptyView(message: 'Your cart is empty.'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: CartCouponField(
                    key: ValueKey('empty-${cart.couponCode}'),
                    couponCode: cart.couponCode,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/products'),
                  child: const Text('Browse products'),
                ),
                const SizedBox(height: 16),
              ],
            ),
            CartReady(:final cart) => CartReadyBody(cart: cart),
          };
        },
      ),
    );
  }
}
