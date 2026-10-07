import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/products_api.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/product.dart';

sealed class ProductsEvent {
  const ProductsEvent();
}

class ProductsRequested extends ProductsEvent {
  const ProductsRequested();
}

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

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc(this._api) : super(const ProductsLoading()) {
    on<ProductsRequested>(_onRequested);
  }

  final ProductsApi _api;

  Future<void> _onRequested(
    ProductsRequested event,
    Emitter<ProductsState> emit,
  ) async {
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
