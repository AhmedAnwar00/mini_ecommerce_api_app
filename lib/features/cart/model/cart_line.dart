class CartLine {
  const CartLine({
    required this.productId,
    required this.name,
    required this.priceMinor,
    required this.quantity,
  });

  final String productId;
  final String name;
  final int priceMinor;
  final int quantity;

  CartLine copyWith({int? quantity}) {
    return CartLine(
      productId: productId,
      name: name,
      priceMinor: priceMinor,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'priceMinor': priceMinor,
    'quantity': quantity,
  };

  factory CartLine.fromJson(Map<String, dynamic> json) {
    final id = json['productId'];
    final quantity = (json['quantity'] as num?)?.toInt();
    final price = (json['priceMinor'] as num?)?.toInt();
    if (id is! String ||
        id.isEmpty ||
        quantity == null ||
        quantity <= 0 ||
        price == null ||
        price < 0) {
      throw const FormatException('Invalid cart line');
    }
    return CartLine(
      productId: id,
      name: json['name'] as String? ?? '',
      priceMinor: price,
      quantity: quantity,
    );
  }
}
