import 'package:flutter/material.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/minor_units_format.dart';
import 'package:mini_ecommerce_app_prompt/features/products/model/product.dart';
import 'package:mini_ecommerce_app_prompt/features/products/view/widgets/add_to_cart_button.dart';

class ProductDetailsContent extends StatelessWidget {
  const ProductDetailsContent({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(formatMinorUnits(product.priceMinor)),
          const SizedBox(height: 16),
          Text(product.description),
          const SizedBox(height: 24),
          AddToCartButton(product: product),
        ],
      ),
    );
  }
}
