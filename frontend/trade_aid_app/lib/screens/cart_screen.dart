// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../models/resource.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> get items => Cart.instance.items;

  double get total => Cart.instance.totalPrice();

  void _openItemDetails(dynamic item) {
    if (item is Product) {
      Navigator.pushNamed(context, '/product_details', arguments: {'product': item})
          .then((_) => setState(() {}));
    } else if (item is Resource) {
      Navigator.pushNamed(context, '/resource_details', arguments: {'resource': item})
          .then((_) => setState(() {}));
    } else {
      // unknown item
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open this item type')),
      );
    }
  }

  String _itemTitle(dynamic item) {
    if (item is Product) return item.name;
    if (item is Resource) return item.name;
    return 'Item';
  }

  String _itemSubtitle(dynamic item) {
    if (item is Product) return 'Rs ${item.price.toStringAsFixed(0)}';
    if (item is Resource) return 'Rs ${item.pricePerHour.toStringAsFixed(0)}/h';
    return '';
  }

  String _itemImage(dynamic item) {
    if (item is Product) return item.image;
    if (item is Resource) return item.image;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final item = items[i];
                final img = _itemImage(item);
                final title = _itemTitle(item);
                final subtitle = _itemSubtitle(item);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    onTap: () => _openItemDetails(item),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        img,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    title: Text(title),
                    subtitle: Text(subtitle),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          Cart.instance.remove(item);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$title removed from cart.')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text('Total: Rs ${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: items.isEmpty
                  ? null
                  : () {
                      // placeholder checkout
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Checkout not implemented')),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
