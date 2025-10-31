// lib/screens/product_details.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'payment_option.dart';
import '../models/product.dart';
import '../models/cart.dart';

// 🎨 Shared color palette
const Color kPrimaryTeal = Color(0xFF004D40); // main teal used across the UI
const Color kLightTeal = Color(0xFF70B2B2); // lighter teal accent
const Color kSkyBlue = Color(0xFF9ECFD4);   // soft blue used for accents

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    String safeString(dynamic Function() getter) {
      try {
        final v = getter();
        if (v == null) return 'N/A';
        return v.toString();
      } catch (_) {
        return 'N/A';
      }
    }

    final imagePath = safeString(() => (product as dynamic).image);
    final name = safeString(() => product.name);
    final description = safeString(() => product.description);
    final priceText = 'Rs ${product.price.toStringAsFixed(0)}';
    final condition = safeString(() => (product as dynamic).condition);
    final usedTime = safeString(() => (product as dynamic).usedTime);
    final sellerName = safeString(() => (product as dynamic).sellerName);
    final sellerAddressFull = safeString(() => (product as dynamic).sellerAddress);
    final addressParts = sellerAddressFull.split(',');
    final houseNumber = addressParts.isNotEmpty ? addressParts[0].trim() : 'N/A';
    final addressRest = addressParts.length > 1
        ? addressParts.sublist(1).join(',').trim()
        : sellerAddressFull;

    const double bottomBarHeight = 84.0;
    final double deviceInset = MediaQuery.of(context).padding.bottom;
    final double scrollReserve = bottomBarHeight + deviceInset + 12.0;

    final Color cardBg = Colors.white;
    final Color softBg = kSkyBlue.withOpacity(0.2);
    final TextStyle sectionTitle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: kPrimaryTeal,
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: kPrimaryTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: kPrimaryTeal),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18, 18, 18, scrollReserve),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE with teal outline
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: kPrimaryTeal, width: 3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
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
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryTeal,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kLightTeal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // SHORT DESCRIPTION
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 14),

            // CONDITION CARD
            Card(
              color: cardBg,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Condition', style: sectionTitle),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: kLightTeal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            condition,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined,
                            size: 18, color: kLightTeal),
                        const SizedBox(width: 8),
                        Text(
                          'Used: $usedTime',
                          style: const TextStyle(color: Colors.black87),
                        ),
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
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: kSkyBlue.withOpacity(0.6), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage('assets/images/seller.jpg'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sellerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: kPrimaryTeal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Warehouse:',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kSkyBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: kSkyBlue),
                                ),
                                child: Text(houseNumber,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            addressRest,
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          color: kPrimaryTeal),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chat feature coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),

      // Bottom bar
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(
                          priceText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kPrimaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentSelectionScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryTeal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Buy',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          Cart.instance.add(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${product.name} added to cart.'),
                            ),
                          );
                          Navigator.pushNamed(context, '/cart');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kLightTeal,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Icon(Icons.shopping_cart,
                            color: Colors.white),
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
