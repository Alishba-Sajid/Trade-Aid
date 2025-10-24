// lib/screens/resource_listing.dart
import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../models/cart.dart'; // added so resources can be added to cart

class ResourceListingScreen extends StatefulWidget {
  const ResourceListingScreen({super.key});

  @override
  State<ResourceListingScreen> createState() => _ResourceListingScreenState();
}

class _ResourceListingScreenState extends State<ResourceListingScreen> {
  String searchQuery = '';

  final List<Resource> resources = [
    Resource(
      id: 'lawn1',
      name: 'Spacious Lawn',
      image: 'assets/lawn.jpg',
      description:
          'A spacious, well-maintained lawn suited for family gatherings, weddings and corporate events.',
      ownerName: 'Hania Bhatti',
      ownerAddress: 'H 256, Block C, Street 2, Gulberg Greens',
      pricePerHour: 2000, // ✅ keep number only
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      availableTime: '24/7',
    ),
    Resource(
      id: 'wash1',
      name: 'Washing Machine',
      image: 'assets/washing_machine.jpg',
      description:
          'High efficiency washing machine available for hourly booking.',
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
      description:
          'Large capacity refrigerator available for parties & events.',
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
        title: const Text(
          'Resources',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF3F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Resource list
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('No resources found',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            searchQuery.trim().isEmpty
                                ? 'Try a different search term.'
                                : 'We couldn\'t find "${searchQuery.trim()}".',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),

                          const SizedBox(height: 14),

                          // Create Wish Request button (no navigation)
                          ElevatedButton.icon(
                            onPressed: () {
                              // placeholder for backend-connected wish creation
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Wish request feature coming soon!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Create Wish Request'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004D40),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final r = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                r.image,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported,
                        size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Right Section: Details + Price + Buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    r.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    r.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.black54,
                        height: 1.3,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 10),

                  // Price and Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Price
                      Text(
                        'Rs ${r.pricePerHour.toStringAsFixed(0)}/h',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),

                      // Buttons side by side
                      Row(
                        children: [
                          // Book button
                          SizedBox(
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/booking',
                                    arguments: {
                                      'resourceId': r.id,
                                      'resourceName': r.name,
                                    });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(1, 107, 97, 1.0),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Book',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Add to cart button
                          SizedBox(
                            height: 38,
                            width: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                // add resource to shared in-memory cart
                                Cart.instance.add(r);

                                // show confirmation with current cart count
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${r.name} added to cart. (${Cart.instance.itemCount})',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                // optional: call setState if you need UI refresh
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
