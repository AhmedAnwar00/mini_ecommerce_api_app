class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMinor,
  });

  final String id;
  final String name;
  final String description;
  final int priceMinor;

  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id == null || id.toString().isEmpty) {
      throw const FormatException('Product id missing');
    }
    final price = (json['priceMinor'] as num?)?.toInt();
    if (price == null || price < 0) {
      throw const FormatException('Product price missing');
    }
    return Product(
      id: id.toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priceMinor: price,
    );
  }
}
