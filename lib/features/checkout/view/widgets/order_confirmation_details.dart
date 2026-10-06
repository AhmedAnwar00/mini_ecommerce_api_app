import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/minor_units_format.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/model/order.dart';

class OrderConfirmationDetails extends StatelessWidget {
  const OrderConfirmationDetails({super.key, required this.placedOrder});

  final PlacedOrder placedOrder;

  @override
  Widget build(BuildContext context) {
    final order = placedOrder.order;
    final updated = order.totalMinor != placedOrder.quotedTotalMinor;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ${order.id}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text('Total ${formatMinorUnits(order.totalMinor)}'),
          if (updated) ...[
            const SizedBox(height: 8),
            const Text('The store updated the total.'),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go('/products'),
            child: const Text('Back to products'),
          ),
        ],
      ),
    );
  }
}
