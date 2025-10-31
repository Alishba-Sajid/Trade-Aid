// lib/models/cart.dart
import 'product.dart';
import '../models/resource.dart';

/// A simple in-memory cart that can hold both Product and Resource items.
/// Each item is stored as dynamic, but we keep helpers to detect type.
class Cart {
  Cart._internal();
  static final Cart _instance = Cart._internal();
  static Cart get instance => _instance;

  final List<dynamic> _items = [];

  /// Returns a read-only list of raw items (Product or Resource)
  List<dynamic> get items => List.unmodifiable(_items);

  /// Adds an item (Product or Resource). Avoids duplicate reference adds.
  void add(dynamic item) {
    if (item == null) return;
    if (!_items.contains(item)) {
      _items.add(item);
    }
  }

  /// Removes given item
  void remove(dynamic item) {
    _items.remove(item);
  }

  /// Clears cart
  void clear() {
    _items.clear();
  }

  /// Returns true if cart contains the item
  bool contains(dynamic item) {
    return _items.contains(item);
  }

  /// Number of items
  int get itemCount => _items.length;

  /// Compute approximate total price.
  /// For Product: use product.price
  /// For Resource: use pricePerHour (this is a simple sum — adapt as needed)
  double totalPrice() {
    double total = 0.0;
    for (final it in _items) {
      if (it is Product) {
        total += it.price.toDouble();
      } else if (it is Resource) {
        total += it.pricePerHour.toDouble();
      } else {
        // ignore unknown types or attempt to read 'price' dynamically
        try {
          final dynamic p = it.price;
          if (p is num) total += p.toDouble();
        } catch (_) {}
      }
    }
    return total;
  }
}
