import '../models/product.dart';

class CartService {
  final List<Product> _items = [];

  List<Product> get items => [..._items];

  void addProduct(Product product) {
    _items.add(product);
  }

  void removeProduct(int index) {
    _items.removeAt(index);
  }

  void clearCart() {
    _items.clear();
  }

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get totalCGST {
    return _items.fold(0, (sum, item) => sum + item.cgst);
  }

  double get totalSGST {
    return _items.fold(0, (sum, item) => sum + item.sgst);
  }

  double get subtotal {
    return _items.fold(0, (sum, item) => sum + item.price);
  }
}
