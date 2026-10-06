import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/widgets/error_view.dart';
import 'package:mini_ecommerce_app_prompt/core/ui/widgets/loading_view.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/viewmodel/cart_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/model/order.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/view/widgets/checkout_body.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/viewmodel/checkout_bloc.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutEmptyCart) {
          context.go('/cart');
        }
        if (state is CheckoutSuccess) {
          context.read<CartBloc>().add(const CartCheckedOut());
          context.go(
            '/checkout/confirmation',
            extra: PlacedOrder(
              order: state.order,
              quotedTotalMinor: state.quotedTotalMinor,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            return switch (state) {
              CheckoutLoading() || CheckoutEmptyCart() => const LoadingView(),
              CheckoutFailure(:final message) => ErrorView(
                message: message,
                onAction: () {
                  context.read<CheckoutBloc>().add(const CheckoutRequested());
                },
              ),
              CheckoutReady(:final draft) => CheckoutBody(
                draft: draft,
                submitting: false,
              ),
              CheckoutSubmitting(:final draft) => CheckoutBody(
                draft: draft,
                submitting: true,
              ),
              CheckoutSubmitFailure(:final draft, :final message) =>
                CheckoutBody(
                  draft: draft,
                  submitting: false,
                  errorMessage: message,
                ),
              CheckoutSuccess() => const LoadingView(),
            };
          },
        ),
      ),
    );
  }
}
