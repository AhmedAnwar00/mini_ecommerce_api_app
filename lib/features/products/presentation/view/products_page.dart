import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/widgets/empty_view.dart';
import 'package:mini_ecommerce_app_prompt/core/ui/widgets/error_view.dart';
import 'package:mini_ecommerce_app_prompt/core/ui/widgets/loading_view.dart';
import 'package:mini_ecommerce_app_prompt/features/products/presentation/view/widgets/product_list.dart';
import 'package:mini_ecommerce_app_prompt/features/products/presentation/view/widgets/session_startup_notice.dart';
import 'package:mini_ecommerce_app_prompt/features/products/presentation/viewmodel/products_bloc.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SessionStartupNotice(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
          actions: [
            IconButton(
              onPressed: () => context.push('/cart'),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
            IconButton(
              onPressed: () => context.push('/profile'),
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
        body: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            return switch (state) {
              ProductsLoading() => const LoadingView(),
              ProductsFailure(:final message) => ErrorView(
                message: message,
                onAction: () {
                  context.read<ProductsBloc>().add(const ProductsRequested());
                },
              ),
              ProductsEmpty() => const EmptyView(message: 'No products yet.'),
              ProductsReady(:final products) => ProductList(products: products),
            };
          },
        ),
      ),
    );
  }
}
