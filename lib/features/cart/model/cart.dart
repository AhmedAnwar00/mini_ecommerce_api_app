import 'package:mini_ecommerce_app_prompt/features/cart/model/cart_line.dart';

class Cart {
  const Cart({required this.lines, this.couponCode});

  final List<CartLine> lines;
  final String? couponCode;

  static const empty = Cart(lines: []);

  Cart copyWith({
    List<CartLine>? lines,
    String? couponCode,
    bool clearCoupon = false,
  }) {
    return Cart(
      lines: lines ?? this.lines,
      couponCode: clearCoupon ? null : couponCode ?? this.couponCode,
    );
  }

  Map<String, dynamic> toJson() => {
    'lines': lines.map((line) => line.toJson()).toList(),
    'couponCode': couponCode,
  };

  factory Cart.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    if (rawLines is! List) throw const FormatException('Cart lines missing');
    final lines = rawLines.map((item) {
      if (item is! Map) throw const FormatException('Invalid cart line');
      return CartLine.fromJson(Map<String, dynamic>.from(item));
    }).toList();
    final coupon = json['couponCode'];
    return Cart(
      lines: lines,
      couponCode: coupon is String && coupon.trim().isNotEmpty
          ? coupon.trim()
          : null,
    );
  }
}
