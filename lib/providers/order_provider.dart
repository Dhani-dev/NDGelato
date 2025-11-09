import 'package:flutter/material.dart';
import '../models/ice_cream_model.dart';

class OrderProvider extends ChangeNotifier {
  // items are maps: {id, name, price, quantity}
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  void addOrIncrement(IceCream ice) {
    final idx = _items.indexWhere((e) => e['id'] == ice.id);
    if (idx >= 0) {
      _items[idx]['quantity'] = (_items[idx]['quantity'] as int) + 1;
    } else {
      _items.add({'id': ice.id, 'name': ice.name, 'price': ice.price, 'quantity': 1});
    }
    notifyListeners();
  }

  void decrementOrRemove(String id) {
    final idx = _items.indexWhere((e) => e['id'] == id);
    if (idx >= 0) {
      final q = _items[idx]['quantity'] as int;
      if (q > 1) {
        _items[idx]['quantity'] = q - 1;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((e) => e['id'] == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get total => _items.fold(0.0, (s, e) => s + ((e['price'] as num).toDouble() * (e['quantity'] as int)));
}
