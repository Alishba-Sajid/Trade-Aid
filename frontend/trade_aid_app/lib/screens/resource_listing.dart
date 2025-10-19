// lib/screens/resource_listing.dart
import 'package:flutter/material.dart';
import '../models/resource.dart';

class ResourceListingScreen extends StatefulWidget {
  const ResourceListingScreen({super.key});

  @override
  State<ResourceListingScreen> createState() => _ResourceListingScreenState();
}

class _ResourceListingScreenState extends State<ResourceListingScreen> {
  String searchQuery = '';

  // Dummy resources for UI testing (no backend required)
  final List<Resource> resources = [
    Resource(
      id: 'lawn1',
      name: 'Spacious Lawn',
      image: 'assets/lawn.jpg',
      description:
          'A spacious, well-maintained lawn suited for family gatherings, weddings and corporate events.',
      ownerName: 'Hania Bhatti',
      ownerAddress: 'H 256, Block C, Street 2, Gulberg Greens',
      pricePerHour: 2000,
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      availableTime: '24/7',
    ),
    Resource(
      id: 'wash1',
      name: 'Washing Machine',
      image: 'assets/washing_machine.jpg',
      description: 'High efficiency washing machine available for hourly booking.',
      ownerName: 'Ali Khan',
      ownerAddress: 'House 12, Sector B, Bahria Town',
      pricePerHour: 300,
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      availableTime: '09:00 - 21:00',
    ),
    Resource(
      id: 'fridge1',
      name: 'Refrigerator',
      image: 'assets/fridge.jpg',
      description: 'Large capacity refrigerator available for parties & events.',
      ownerName: 'Sara Ahmed',
      ownerAddress: 'Street 9, F-10, Islamabad',
      pricePerHour: 500,
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      availableTime: '24/7',
    ),
  ];

  List<Resource> get filteredResources {
    if (searchQuery.trim().isEmpty) return resources;
    final q = searchQuery.toLowerCase();
    return resources.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q) ||
          r.ownerName.toLowerCase().contains(q) ||
          r.ownerAddress.toLowerCase().contains(q);
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    final items = filteredResources;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar (same style as product listing)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('No resources found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            searchQuery.trim().isEmpty ? 'Try a different search term.' : 'We couldn\'t find "${searchQuery.trim()}".',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final r = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/resource_details',
                                arguments: {'resource': r},
                              );
                            },
                            child: _buildResourceRowCard(context, r),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceRowCard(BuildContext context, Resource r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                r.image,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 110,
                    height: 110,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, size: 40),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Main details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(r.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),

                  // Description (2 lines)
                  Text(
                    r.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87, height: 1.3),
                  ),
                  const SizedBox(height: 8),

                  // Availability (days & time)
                  Text(
                    'Avail: ${r.availableDays.join(", ")} • ${r.availableTime}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Owner + chat icon
                  Row(
                    children: [
                      const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/seller.jpg')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.ownerName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Starting chat with ${r.ownerName}')));
                        },
                        tooltip: 'Chat with owner',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Price & Book button column
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rs ${r.pricePerHour.toStringAsFixed(0)}/h', style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      // Keep navigation unchanged: open booking flow (push /booking or details)
                      Navigator.pushNamed(context, '/booking', arguments: {
                        'resourceId': r.id,
                        'resourceName': r.name,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Book', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
