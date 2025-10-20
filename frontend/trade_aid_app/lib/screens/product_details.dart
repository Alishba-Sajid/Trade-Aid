// lib/screens/product_details.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'payment_option.dart'; // <-- added import
import '../models/product.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // safe reader for optional fields
    String safeString(dynamic Function() getter) {
      try {
        final v = getter();
        if (v == null) return 'N/A';
        return v.toString();
      } catch (_) {
        return 'N/A';
      }
    }

    // core fields
    final imagePath = safeString(() => (product as dynamic).image);
    final name = safeString(() => product.name);
    final description = safeString(() => product.description);
    final priceText = 'Rs ${product.price.toStringAsFixed(0)}';

    // optional/extended fields
    final condition = safeString(() => (product as dynamic).condition);
    final usedTime = safeString(() => (product as dynamic).usedTime);

    // seller fields (address parsing like your resource example)
    final sellerName = safeString(() => (product as dynamic).sellerName);
    final sellerAddressFull = safeString(() => (product as dynamic).sellerAddress);
    final addressParts = sellerAddressFull.split(',');
    final houseNumber = addressParts.isNotEmpty ? addressParts[0].trim() : 'N/A';
    final addressRest = addressParts.length > 1 ? addressParts.sublist(1).join(',').trim() : sellerAddressFull;

    // bottom bar sizing
    const double bottomBarHeight = 84.0;

    // device bottom inset
    final double deviceInset = MediaQuery.of(context).padding.bottom;

    // scroll reserve: include device inset and a small margin so content doesn't jam the bar
    final double scrollReserve = bottomBarHeight + deviceInset + 12.0;

    // subtle colors
    final Color cardBg = Colors.white;
    final Color softBg = const Color(0xFFF7F6FB); // faint lilac-ish
    final TextStyle sectionTitle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Product Details',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18, 18, 18, scrollReserve),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE: aspect ratio + contain to avoid cropping
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: softBg,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // NAME + PRICE row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Text(priceText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),

            const SizedBox(height: 10),

            // SHORT DESCRIPTION
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87, height: 1.45),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 14),

            // CONDITION CARD
            Card(
              color: cardBg,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Condition', style: sectionTitle),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(condition, style: const TextStyle(color: Colors.black87))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Used: $usedTime', style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // SELLER CARD
            Card(
              color: cardBg,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // avatar with subtle border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                      ),
                      child: const CircleAvatar(radius: 22, backgroundImage: AssetImage('assets/images/seller.jpg')),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sellerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('House:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(width: 6),
                              Text(houseNumber, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(addressRest,
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),

                    // Chat button (rounded square)
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.teal, size: 20),
                        tooltip: 'Chat with seller',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Starting chat with $sellerName')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),


          ],
        ),
      ),

      // Bottom bar as bottomNavigationBar so it is always flush at the bottom
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                height: bottomBarHeight,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Price column
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(priceText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const Spacer(),

                    // Buy button
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          // navigate to payment selection screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PaymentSelectionScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Buy', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Add to cart (icon button)
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Icon(Icons.add_shopping_cart_outlined, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
