import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/minor_units_format.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(formatMinorUnits(product.priceMinor)),
        onTap: () => context.push('/products/${product.id}'),
      ),
    );
  }
}
