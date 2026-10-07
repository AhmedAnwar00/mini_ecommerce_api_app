import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/features/product_details/presentation/viewmodel/product_details_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/product.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/products_api.dart';

void main() {
  const product = Product(
    id: 'p1',
    name: 'Lamp',
    description: 'Desk lamp',
    priceMinor: 2500,
  );

  test('starts in loading', () async {
    final cubit = ProductDetailsCubit(_FakeProductsApi(product), product.id);

    expect(cubit.state, isA<ProductDetailsLoading>());
    await cubit.close();
  });

  test('emits loading then the product', () async {
    final cubit = ProductDetailsCubit(_FakeProductsApi(product), product.id);
    final states = cubit.stream.take(2).toList();

    await cubit.loadProduct();

    final emitted = await states;
    expect(emitted[0], isA<ProductDetailsLoading>());
    final ready = emitted[1] as ProductDetailsReady;
    expect(ready.product.id, product.id);
    expect(ready.product.name, product.name);
    await cubit.close();
  });

  test('emits not found when the product is missing', () async {
    final cubit = ProductDetailsCubit(
      _FakeProductsApi(
        product,
        failure: const AppFailure(AppFailureKind.notFound, 'Missing'),
      ),
      product.id,
    );

    await cubit.loadProduct();

    expect(cubit.state, isA<ProductDetailsNotFound>());
    await cubit.close();
  });

  test('emits a failure message from the api', () async {
    final cubit = ProductDetailsCubit(
      _FakeProductsApi(
        product,
        failure: const AppFailure(AppFailureKind.network, 'Offline'),
      ),
      product.id,
    );

    await cubit.loadProduct();

    expect((cubit.state as ProductDetailsFailure).message, 'Offline');
    await cubit.close();
  });
}

class _FakeProductsApi implements ProductsApi {
  _FakeProductsApi(this.product, {this.failure});

  final Product product;
  final AppFailure? failure;

  @override
  Future<Product> getProduct(String id) async {
    final failure = this.failure;
    if (failure != null) throw failure;
    return product;
  }

  @override
  Future<List<Product>> getProducts() async => [product];
}
