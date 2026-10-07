import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/products_api.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/product.dart';

sealed class ProductDetailsEvent {
  const ProductDetailsEvent();
}

class ProductDetailsRequested extends ProductDetailsEvent {
  const ProductDetailsRequested();
}

sealed class ProductDetailsState {
  const ProductDetailsState();
}

class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

class ProductDetailsFailure extends ProductDetailsState {
  const ProductDetailsFailure(this.message);

  final String message;
}

class ProductDetailsNotFound extends ProductDetailsState {
  const ProductDetailsNotFound();
}

class ProductDetailsReady extends ProductDetailsState {
  const ProductDetailsReady(this.product);

  final Product product;
}

class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  ProductDetailsBloc(this._api, this.productId)
    : super(const ProductDetailsLoading()) {
    on<ProductDetailsRequested>(_onRequested);
  }

  final ProductsApi _api;
  final String productId;

  Future<void> _onRequested(
    ProductDetailsRequested event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(const ProductDetailsLoading());
    try {
      final product = await _api.getProduct(productId);
      emit(ProductDetailsReady(product));
    } on AppFailure catch (failure) {
      if (failure.kind == AppFailureKind.notFound) {
        emit(const ProductDetailsNotFound());
        return;
      }
      emit(ProductDetailsFailure(failure.message));
    }
  }
}
