import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  void addProduct(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void removeProduct(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
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
