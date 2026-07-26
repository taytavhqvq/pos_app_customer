import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get totalQty => _items.fold(0, (sum, item) => sum + item.qty);
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.lineTotal);
  bool get isEmpty => _items.isEmpty;

  void addItem(ProductModel product, ProductUnitModel unit, int qty) {
    final key = '${product.proid}_${unit.uid}';
    final existingIndex = _items.indexWhere((i) => i.cartKey == key);

    if (existingIndex >= 0) {
      _items[existingIndex].qty += qty;
    } else {
      _items.add(CartItemModel(product: product, unit: unit, qty: qty));
    }
    notifyListeners();
  }

  void updateQty(String cartKey, int qty) {
    if (qty < 1) return;
    final index = _items.indexWhere((i) => i.cartKey == cartKey);
    if (index >= 0) {
      _items[index].qty = qty;
      notifyListeners();
    }
  }

  void removeItem(String cartKey) {
    _items.removeWhere((i) => i.cartKey == cartKey);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  // แปลงเป็น payload สำหรับ POST /orders/online
  List<Map<String, dynamic>> toOrderPayload() {
    return _items
        .map((i) => {'proid': i.product.proid, 'uid': i.unit.uid, 'qty': i.qty})
        .toList();
  }
}
