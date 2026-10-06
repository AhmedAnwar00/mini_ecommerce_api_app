import 'package:mini_ecommerce_app_prompt/features/products/model/product.dart';

abstract class ProductsApi {
  Future<List<Product>> getProducts();

  Future<Product> getProduct(String id);
}
