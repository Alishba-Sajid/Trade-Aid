import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/resource.dart';

/// Manages cart items and their individual 15-minute holds.
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  Timer? _expiryTimer;

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice => _items.fold(0.0, (sum, i) => sum + i.price);

  void _ensureTimer() {
    _expiryTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (_items.isEmpty) {
        _expiryTimer?.cancel();
        _expiryTimer = null;
        return;
      }
      final now = DateTime.now();
      _items.removeWhere((item) => item.expiresAt.isBefore(now));
      // Always notify so countdowns update.
      if (_items.isEmpty) {
        _expiryTimer?.cancel();
        _expiryTimer = null;
      }
      notifyListeners();
    });
  }

  void addProduct(Product product) {
    _items.add(CartItem.fromProduct(product));
    _ensureTimer();
    notifyListeners();
  }

  void addResource(Resource resource) {
    _items.add(CartItem.fromResource(resource));
    _ensureTimer();
    notifyListeners();
  }

  void removeItemAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    if (_items.isEmpty) {
      _expiryTimer?.cancel();
      _expiryTimer = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _expiryTimer?.cancel();
    _expiryTimer = null;
    notifyListeners();
  }

  /// Remaining time for a specific cart item.
  Duration remainingForItem(CartItem item) {
    return item.remainingAt(DateTime.now());
  }

  /// Whether a product with [productId] is currently held in this cart.
  bool isProductHeld(String productId) {
    final now = DateTime.now();
    return _items.any(
      (item) =>
          item.isProduct &&
          item.product != null &&
          item.product!.id == productId &&
          item.expiresAt.isAfter(now),
    );
  }

  /// Remaining time for a product's hold in this cart.
  Duration remainingForProduct(String productId) {
    final now = DateTime.now();
    final remainingDurations = _items
        .where(
          (item) =>
              item.isProduct &&
              item.product != null &&
              item.product!.id == productId &&
              item.expiresAt.isAfter(now),
        )
        .map((item) => item.remainingAt(now))
        .toList();

    if (remainingDurations.isEmpty) return Duration.zero;
    remainingDurations.sort((a, b) => a.compareTo(b));
    return remainingDurations.first;
  }

  /// Call when user completes checkout so cart is cleared and timer stopped.
  void onCheckoutSuccess() {
    clearCart();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }
}
