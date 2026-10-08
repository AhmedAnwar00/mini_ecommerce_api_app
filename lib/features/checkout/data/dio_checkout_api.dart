import 'package:dio/dio.dart';

import 'package:mini_ecommerce_app_prompt/core/network/dio_client.dart';
import 'package:mini_ecommerce_app_prompt/core/network/json_body.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_line.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/checkout_api.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/order.dart';

class DioCheckoutApi implements CheckoutApi {
  DioCheckoutApi(this._dio);

  final Dio _dio;

  @override
  Future<Order> placeOrder({
    required List<CartLine> lines,
    required String? couponCode,
  }) {
    return runRequest(() async {
      final response = await _dio.post<Object?>(
        '/orders',
        data: {
          'lines': [
            for (final line in lines)
              {'productId': line.productId, 'quantity': line.quantity},
          ],
          'couponCode': couponCode,
        },
      );
      return Order.fromJson(requireJsonMap(response.data));
    });
  }
}
