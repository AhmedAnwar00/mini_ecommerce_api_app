import 'package:flutter/material.dart';

import 'package:mini_ecommerce_app_prompt/features/products/model/product.dart';
import 'package:mini_ecommerce_app_prompt/features/products/view/widgets/product_card.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final product in products) ...[
          ProductCard(product: product),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
