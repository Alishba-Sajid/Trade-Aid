import 'product.dart';
import 'resource.dart';

/// Per-item hold duration for cart entries.
const Duration cartItemHoldDuration = Duration(minutes: 15);

enum CartItemType { product, resource }

/// Single cart entry: either a product or a resource.
/// Each entry has its own 15-minute hold timer.
class CartItem {
  final CartItemType type;
  final String uniqueId;
  final Product? product;
  final Resource? resource;
  final DateTime addedAt;

  CartItem._({
    required this.type,
    required this.uniqueId,
    required this.addedAt,
    this.product,
    this.resource,
  });

  factory CartItem.fromProduct(Product p) {
    final now = DateTime.now();
    return CartItem._(
      type: CartItemType.product,
      uniqueId: 'product_${p.id}_${now.millisecondsSinceEpoch}',
      addedAt: now,
      product: p,
      resource: null,
    );
  }

  factory CartItem.fromResource(Resource r) {
    final now = DateTime.now();
    return CartItem._(
      type: CartItemType.resource,
      uniqueId: 'resource_${r.id}_${now.millisecondsSinceEpoch}',
      addedAt: now,
      product: null,
      resource: r,
    );
  }

  String get name => product?.name ?? resource!.name;
  double get price => product?.price ?? resource!.pricePerHour;
  String get description => product?.description ?? resource!.description;
  String get sellerName => product?.sellerName ?? resource!.ownerName;

  String get imageUrl {
    if (product != null && product!.images.isNotEmpty) {
      return product!.images.first;
    }
    if (resource != null && resource!.images.isNotEmpty) {
      return resource!.images.first;
    }
    return '';
  }

  /// When this cart entry expires.
  DateTime get expiresAt => addedAt.add(cartItemHoldDuration);

  /// Remaining time for this entry as of [now].
  Duration remainingAt(DateTime now) {
    final diff = expiresAt.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isProduct => type == CartItemType.product;
}
