import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/widgets/empty_view.dart';
import 'package:mini_ecommerce_app_prompt/core/ui/widgets/error_view.dart';
import 'package:mini_ecommerce_app_prompt/core/ui/widgets/loading_view.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/order.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/presentation/view/widgets/checkout_body.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/presentation/viewmodel/checkout_cubit.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
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
        body: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, state) {
            return switch (state) {
              CheckoutLoading() => const LoadingView(),
              CheckoutEmptyCart() => EmptyView(
                message: 'Your cart is empty.',
                actionLabel: 'Back to cart',
                onAction: () => context.go('/cart'),
              ),
              CheckoutFailure(:final message) => ErrorView(
                message: message,
                onAction: () {
                  context.read<CheckoutCubit>().load();
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
