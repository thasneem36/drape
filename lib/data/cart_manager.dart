import 'package:flutter/foundation.dart';
import 'models.dart';
import 'dummy_data.dart';

class CartManager extends ChangeNotifier {
  final List<CartItem> items = [];

  int get itemCount => items.fold(0, (a, b) => a + b.qty);

  double subtotal() => items.fold(0.0, (a, i) {
    final p = DummyData.byId(i.productId);
    return a + p.price * i.qty;
  });

  void seed() {
    items
      ..clear()
      ..addAll([
        CartItem(productId: 'p_001', size: 'S', color: 'Black'),
        CartItem(productId: 'p_007', size: 'M', color: 'Cream'),
      ]);
  }

  void add(Product p, String size, String color, {int qty = 1}) {
    final idx = items.indexWhere((i) => i.productId == p.id && i.size == size && i.color == color);
    if (idx >= 0) { items[idx].qty += qty; } else {
      items.add(CartItem(productId: p.id, size: size, color: color, qty: qty));
    }
    notifyListeners();
  }

  void removeAt(int i) { items.removeAt(i); notifyListeners(); }
  void setQty(int i, int qty) { items[i].qty = qty.clamp(1, 99); notifyListeners(); }
  void clear() { items.clear(); notifyListeners(); }
}
