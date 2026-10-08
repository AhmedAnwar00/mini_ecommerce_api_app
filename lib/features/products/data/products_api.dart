import 'package:mini_ecommerce_app_prompt/features/products/data/product.dart';

abstract class ProductsApi {
  Future<List<Product>> getProducts();

  Future<Product> getProduct(String id);
}
