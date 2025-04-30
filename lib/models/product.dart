class Product {
  final String name;
  final double price;
  final double gstRate;
  final double cgst;
  final double sgst;
  final double totalPrice;

  Product({required this.name, required this.price, required this.gstRate})
    : cgst = (price * gstRate) / 2,
      sgst = (price * gstRate) / 2,
      totalPrice = price + (price * gstRate);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'gstRate': gstRate,
      'cgst': cgst,
      'sgst': sgst,
      'totalPrice': totalPrice,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'],
      price: map['price'],
      gstRate: map['gstRate'],
    );
  }
}
