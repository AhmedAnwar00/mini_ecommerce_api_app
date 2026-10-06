import 'package:mini_ecommerce_app_prompt/features/checkout/domain/money.dart';

class CheckoutPolicy {
  const CheckoutPolicy({
    required this.minimumOrder,
    required this.vatBasisPoints,
    required this.flatShipping,
    required this.freeShippingThreshold,
  });

  final Money minimumOrder;
  final int vatBasisPoints;
  final Money flatShipping;
  final Money freeShippingThreshold;

  static const standard = CheckoutPolicy(
    minimumOrder: Money(5000),
    vatBasisPoints: 1400,
    flatShipping: Money(1500),
    freeShippingThreshold: Money(20000),
  );
}
