// lib/screens/resource_details.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/resource.dart';

class ResourceDetailsScreen extends StatelessWidget {
  final Resource resource;
  const ResourceDetailsScreen({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    // safe reader
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
    final addressRest = addressParts.length > 1 ? addressParts.sublist(1).join(',').trim() : ownerAddressFull;

    // visible bar height (design height)
    const double bottomBarHeight = 84.0;

    // device bottom inset (home indicator / gesture area)
    final double deviceBottomInset = MediaQuery.of(context).padding.bottom;

    // Reserve exactly enough scroll space so content doesn't get hidden behind the bottom bar.
    // We add a small 8 px margin so content isn't flush against the bar.
    final double scrollReserve = bottomBarHeight + deviceBottomInset + 8.0;

    return Scaffold(
      extendBody: true, // allow translucent/backdrop effect if desired
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Resource Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      // Main content
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, scrollReserve),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 240,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 16, bottom: 2),
                    child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // 2) Name + price inline (price shown to the right of name)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Text(priceText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 13),

            // 3) Description
            Text(description, style: const TextStyle(color: Colors.black87, height: 1.4)),
            const SizedBox(height: 14),

            // Divider
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),

            // Availability Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Availability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(days, style: const TextStyle(color: Colors.black87))),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(time, style: const TextStyle(color: Colors.black87)),
                  ]),
                ]),
              ),
            ),

            const SizedBox(height: 12),

            // Provider Card (name, house number, address, chat icon)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const CircleAvatar(radius: 22, backgroundImage: AssetImage('assets/seller.jpg')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ownerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Text('House:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(houseNumber, style: const TextStyle(fontSize: 13)),
                      ]),
                      const SizedBox(height: 8),
                      Text(addressRest, style: const TextStyle(color: Colors.black54, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                    tooltip: 'Chat with provider',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Starting chat with $ownerName')));
                    },
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // Put the Book Now bar into bottomNavigationBar wrapped with SafeArea
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
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // Price column on bottom left
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

                    // Book Now button
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
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Book Now', style: TextStyle(fontSize: 16, color: Colors.white)),
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
