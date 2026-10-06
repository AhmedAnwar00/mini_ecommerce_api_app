import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CartCheckoutBar extends StatelessWidget {
  const CartCheckoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () => context.push('/checkout'),
          child: const Text('Checkout'),
        ),
      ),
    );
  }
}
