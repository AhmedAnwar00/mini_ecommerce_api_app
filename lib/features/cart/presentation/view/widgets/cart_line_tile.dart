import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/minor_units_format.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_line.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/viewmodel/cart_cubit.dart';

class CartLineTile extends StatelessWidget {
  const CartLineTile({super.key, required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(formatMinorUnits(line.priceMinor)),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<CartCubit>().decreaseQuantity(line.productId);
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text('${line.quantity}'),
                IconButton(
                  onPressed: () {
                    context.read<CartCubit>().increaseQuantity(line.productId);
                  },
                  icon: const Icon(Icons.add),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    context.read<CartCubit>().removeLine(line.productId);
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
