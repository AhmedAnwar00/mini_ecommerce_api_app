import 'package:mini_ecommerce_app_prompt/features/checkout/domain/money.dart';

class CheckoutQuote {
  const CheckoutQuote({
    required this.merchandise,
    required this.couponDiscount,
    required this.membershipDiscount,
    required this.taxable,
    required this.vat,
    required this.shipping,
    required this.total,
    required this.minimumOrder,
    required this.meetsMinimum,
    required this.canPlaceOrder,
  });

  final Money merchandise;
  final Money couponDiscount;
  final Money membershipDiscount;
  final Money taxable;
  final Money vat;
  final Money shipping;
  final Money total;
  final Money minimumOrder;
  final bool meetsMinimum;
  final bool canPlaceOrder;

  static const empty = CheckoutQuote(
    merchandise: Money.zero,
    couponDiscount: Money.zero,
    membershipDiscount: Money.zero,
    taxable: Money.zero,
    vat: Money.zero,
    shipping: Money.zero,
    total: Money.zero,
    minimumOrder: Money.zero,
    meetsMinimum: false,
    canPlaceOrder: false,
  );
}
