import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/products_api.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/product.dart';

sealed class ProductsState {
  const ProductsState();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsFailure extends ProductsState {
  const ProductsFailure(this.message);

  final String message;
}

class ProductsEmpty extends ProductsState {
  const ProductsEmpty();
}

class ProductsReady extends ProductsState {
  const ProductsReady(this.products);

  final List<Product> products;
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._api) : super(const ProductsLoading());

  final ProductsApi _api;

  Future<void> loadProducts() async {
    emit(const ProductsLoading());
    try {
      final products = await _api.getProducts();
      if (products.isEmpty) {
        emit(const ProductsEmpty());
        return;
      }
      emit(ProductsReady(products));
    } on AppFailure catch (failure) {
      emit(ProductsFailure(failure.message));
    }
  }
}
