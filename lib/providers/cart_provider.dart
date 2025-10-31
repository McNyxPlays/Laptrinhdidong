import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../services/firebase_service.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  int _total = 0;

  List<Map<String, dynamic>> get items => _items;
  int get total => _total;

  Future<void> fetchCart() async {
    if (FirebaseService.currentUser != null) {
      final data = await FirebaseService.getCart();
      _items = List.from(data['items'] ?? []);
      _total = data['total'] ?? 0;
    }
    notifyListeners();
  }

  Future<void> addToCart(String cakeId, String size, int quantity) async {
    final cake = await FirebaseService.getCakeById(cakeId);
    final multiplier = {'Nhỏ': 1.0, 'Trung bình': 1.5, 'Lớn': 2.0}[size] ?? 1.0;
    final price = (cake.price * multiplier).toInt();

    if (FirebaseService.currentUser != null) {
      await FirebaseService.addToCart(cakeId, size, quantity);
      await fetchCart();
    } else {
      // Guest: Local cart
      final existing = _items.firstWhere(
        (i) => i['cakeId'] == cakeId && i['size'] == size,
        orElse: () => {},
      );
      if (existing.isNotEmpty) {
        existing['quantity'] += quantity;
        existing['subtotal'] = existing['quantity'] * price;
      } else {
        _items.add({
          'cakeId': cakeId,
          'name': cake.name,
          'image': cake.image,
          'size': size,
          'price': price,
          'quantity': quantity,
          'subtotal': quantity * price,
        });
      }
      _total = _items.map((i) => i['subtotal'] as int).sum;
      notifyListeners();
    }
  }

  void updateItem(String cakeId, String size, int quantity) {
    if (FirebaseService.currentUser != null) {
      FirebaseService.updateCartItem(cakeId, size, quantity);
      fetchCart();
    } else {
      final item = _items.firstWhere(
        (i) => i['cakeId'] == cakeId && i['size'] == size,
      );
      if (quantity <= 0) {
        _items.remove(item);
      } else {
        item['quantity'] = quantity;
        item['subtotal'] = quantity * item['price'];
      }
      _total = _items.map((i) => i['subtotal'] as int).sum;
      notifyListeners();
    }
  }

  void removeItem(String cakeId, String size) {
    if (FirebaseService.currentUser != null) {
      FirebaseService.removeCartItem(cakeId, size);
      fetchCart();
    } else {
      _items.removeWhere((i) => i['cakeId'] == cakeId && i['size'] == size);
      _total = _items.map((i) => i['subtotal'] as int).sum;
      notifyListeners();
    }
  }

  void clear() {
    _items = [];
    _total = 0;
    notifyListeners();
  }
}
