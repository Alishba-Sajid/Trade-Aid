// lib/screens/resource_details.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../models/cart.dart';

// 🎨 Shared color palette
const Color kPrimaryTeal = Color(0xFF004D40); // main teal used across the UI
const Color kLightTeal = Color(0xFF70B2B2);   // lighter teal accent
const Color kSkyBlue = Color(0xFF9ECFD4);     // soft blue used for placeholders

class ResourceDetailsScreen extends StatelessWidget {
  final Resource resource;
  const ResourceDetailsScreen({super.key, required this.resource});

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

    final imagePath = safeString(() => resource.image);
    final name = safeString(() => resource.name);
    final description = safeString(() => resource.description);
    final priceText = 'Rs ${resource.pricePerHour.toStringAsFixed(0)}/h';
    final days = resource.availableDays.join(', ');
    final time = safeString(() => resource.availableTime);
    final ownerName = safeString(() => resource.ownerName);
    final ownerAddressFull = safeString(() => resource.ownerAddress);

    final addressParts = ownerAddressFull.split(',');
    final houseNumber = addressParts.isNotEmpty ? addressParts[0].trim() : 'N/A';
    final addressRest = addressParts.length > 1
        ? addressParts.sublist(1).join(',').trim()
        : ownerAddressFull;

    const double bottomBarHeight = 84.0;
    final double deviceBottomInset = MediaQuery.of(context).padding.bottom;
    final double scrollReserve = bottomBarHeight + deviceBottomInset + 8.0;

    final Color softBg = kSkyBlue.withOpacity(0.15);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Resource Details',
          style: TextStyle(
            color: kPrimaryTeal,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: kPrimaryTeal),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, scrollReserve),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Image section with teal outline
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: kPrimaryTeal, width: 2),
                borderRadius: BorderRadius.circular(14),
                color: softBg,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                          color: kLightTeal,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 🧾 Name + Price
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 13),

            // 📖 Description
            Text(
              description,
              style: const TextStyle(
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),

            // 📅 Availability (pure white card)
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: kSkyBlue.withOpacity(0.3)),
              ),
              elevation: 3,
              shadowColor: kSkyBlue.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Availability',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kPrimaryTeal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: kLightTeal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(days,
                              style: const TextStyle(color: Colors.black87)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 18, color: kLightTeal),
                        const SizedBox(width: 8),
                        Text(time,
                            style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 👤 Provider Info (pure white)
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: kSkyBlue.withOpacity(0.3))),
              elevation: 3,
              shadowColor: kSkyBlue.withOpacity(0.4),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/seller.jpg'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ownerName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: kPrimaryTeal)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('House:',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                              const SizedBox(width: 6),
                              Text(houseNumber,
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(addressRest,
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: kPrimaryTeal),
                      tooltip: 'Chat with provider',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Starting chat with $ownerName')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),

      // 🛒 Bottom Action Bar
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                height: bottomBarHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: kSkyBlue.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // Price
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
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

                    // Book Now Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/booking', arguments: {
                            'resourceId': resource.id,
                            'resourceName': resource.name,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryTeal,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Book Now',
                          style:
                              TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Add to Cart Button
                    SizedBox(
                      height: 48,
                      width: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Cart.instance.add(resource);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${resource.name} added to cart')),
                          );
                          Navigator.pushNamed(context, '/cart');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kLightTeal,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Icon(Icons.shopping_cart,
                            color: Colors.white, size: 22),
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
