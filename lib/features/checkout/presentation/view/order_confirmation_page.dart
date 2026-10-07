import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/widgets/error_view.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/order.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/presentation/view/widgets/order_confirmation_details.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key, required this.placedOrder});

  final PlacedOrder? placedOrder;

  @override
  Widget build(BuildContext context) {
    final order = placedOrder;
    return Scaffold(
      appBar: AppBar(title: const Text('Order confirmed')),
      body: order == null
          ? ErrorView(
              message: 'This confirmation is no longer available.',
              actionLabel: 'Back to products',
              onAction: () => context.go('/products'),
            )
          : OrderConfirmationDetails(placedOrder: order),
    );
  }
}
