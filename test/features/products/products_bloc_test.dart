import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/products_api.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/product.dart';
import 'package:mini_ecommerce_app_prompt/features/products/presentation/viewmodel/products_bloc.dart';

void main() {
  test('emits empty when the catalog has no products', () async {
    final bloc = ProductsBloc(FakeProductsApi(const []));

    bloc.add(const ProductsRequested());
    final state = await bloc.stream.firstWhere(
      (value) => value is ProductsEmpty || value is ProductsFailure,
    );

    expect(state, isA<ProductsEmpty>());
    await bloc.close();
  });

  test('emits a failure message from the api', () async {
    final bloc = ProductsBloc(
      FakeProductsApi(
        const [],
        failure: const AppFailure(AppFailureKind.network, 'Offline'),
      ),
    );

    bloc.add(const ProductsRequested());
    final state = await bloc.stream.firstWhere(
      (value) => value is ProductsFailure,
    );

    expect((state as ProductsFailure).message, 'Offline');
    await bloc.close();
  });
}

class FakeProductsApi implements ProductsApi {
  FakeProductsApi(this.products, {this.failure});

  final List<Product> products;
  final AppFailure? failure;

  @override
  Future<Product> getProduct(String id) async => products.first;

  @override
  Future<List<Product>> getProducts() async {
    final failure = this.failure;
    if (failure != null) throw failure;
    return products;
  }
}
