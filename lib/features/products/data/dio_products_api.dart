import 'package:dio/dio.dart';

import 'package:mini_ecommerce_app_prompt/core/network/dio_client.dart';
import 'package:mini_ecommerce_app_prompt/core/network/json_body.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/products_api.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/product.dart';

class DioProductsApi implements ProductsApi {
  DioProductsApi(this._dio);

  final Dio _dio;

  @override
  Future<List<Product>> getProducts() {
    return runRequest(() async {
      final response = await _dio.get<Object?>('/products');
      return requireJsonList(
        response.data,
      ).map((item) => Product.fromJson(requireJsonMap(item))).toList();
    });
  }

  @override
  Future<Product> getProduct(String id) {
    return runRequest(() async {
      final response = await _dio.get<Object?>('/products/$id');
      return Product.fromJson(requireJsonMap(response.data));
    });
  }
}
