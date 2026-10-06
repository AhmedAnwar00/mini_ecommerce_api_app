class Order {
  const Order({required this.id, required this.totalMinor});

  final String id;
  final int totalMinor;

  factory Order.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final total = (json['totalMinor'] as num?)?.toInt();
    if (id == null || id.toString().isEmpty || total == null || total < 0) {
      throw const FormatException('Order is incomplete');
    }
    return Order(id: id.toString(), totalMinor: total);
  }
}

class PlacedOrder {
  const PlacedOrder({required this.order, required this.quotedTotalMinor});

  final Order order;
  final int quotedTotalMinor;
}
