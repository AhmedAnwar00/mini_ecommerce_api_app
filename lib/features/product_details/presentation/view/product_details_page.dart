import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/widgets/empty_view.dart';
import 'package:mini_ecommerce_app_prompt/core/ui/widgets/error_view.dart';
import 'package:mini_ecommerce_app_prompt/core/ui/widgets/loading_view.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/viewmodel/cart_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/product_details/presentation/view/widgets/product_details_content.dart';
import 'package:mini_ecommerce_app_prompt/features/product_details/presentation/viewmodel/product_details_cubit.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
          builder: (context, state) {
            return switch (state) {
              ProductDetailsLoading() => const LoadingView(),
              ProductDetailsFailure(:final message) => ErrorView(
                message: message,
                onAction: () {
                  context.read<ProductDetailsCubit>().loadProduct();
                },
              ),
              ProductDetailsNotFound() => EmptyView(
                message: 'This product is not available.',
                actionLabel: 'Back to products',
                onAction: () => context.go('/products'),
              ),
              ProductDetailsReady(:final product) => ProductDetailsContent(
                product: product,
              ),
            };
          },
        ),
      ),
    );
  }
}
