import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/features/cart/viewmodel/cart_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/products/model/product.dart';

class AddToCartButton extends StatelessWidget {
  const AddToCartButton({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        context.read<CartBloc>().add(CartProductAdded(product));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to cart')));
      },
      child: const Text('Add to cart'),
    );
  }
}
