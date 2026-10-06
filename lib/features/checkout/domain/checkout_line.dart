import 'package:mini_ecommerce_app_prompt/features/checkout/domain/money.dart';

class CheckoutLine {
  const CheckoutLine({required this.price, required this.quantity});

  final Money price;
  final int quantity;
}
