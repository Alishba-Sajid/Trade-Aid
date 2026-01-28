import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'post_wish_request.dart';
import '../models/resource.dart';

// 🌿 Premium Color Constants
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Color dark = Color(0xFF004D40);
const Color light = Color(0xFFF0F9F8);
const Color accent = Color(0xFF119E90);

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
      images: ['assets/lawn.jpg'],
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
      images: ['assets/washing_machine.jpg', 'assets/machine2.png'],
      description:
          'High efficiency washing machine available for hourly booking.',
      ownerName: 'Ali Khan',
      ownerAddress: 'House 12, Sector B, Bahria Town',
      pricePerHour: 300,
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu'],
      availableTime: '09:00 - 21:00',
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
      backgroundColor: light,
      body: Column(
        children: [
          _buildPremiumAppBar(context),
          Container(
            color: light,
            padding: const EdgeInsets.all(16),
            child: _buildSearchBar(),
          ),
          Expanded(
            child: items.isEmpty
                ? _buildNoResourcesFound()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final r = items[index];
                      return _buildPremiumResourceCard(context, r);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 🔹 App Bar
  Widget _buildPremiumAppBar(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(gradient: appGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Text(
                "Resources",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (v) => setState(() => searchQuery = v),
      decoration: InputDecoration(
        hintText: 'Search resources',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ⭐ Resource Card with Image Slider
  Widget _buildPremiumResourceCard(BuildContext context, Resource r) {
    int currentImageIndex = 0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/resource_details',
          arguments: {'resource': r},
        );
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: dark.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE SLIDER
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: accent.withOpacity(0.2),
                      width: 1.2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: PageView.builder(
                            itemCount: r.images.length,
                            onPageChanged: (index) {
                              setState(() {
                                currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.asset(
                                r.images[index],
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              );
                            },
                          ),
                        ),
                        if (r.images.length > 1)
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                r.images.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: currentImageIndex == index ? 8 : 6,
                                  height: currentImageIndex == index ? 8 : 6,
                                  decoration: BoxDecoration(
                                    color: currentImageIndex == index
                                        ? accent
                                        : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // NAME & PRICE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        r.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: dark,
                        ),
                      ),
                    ),
                    Text(
                      'Rs ${r.pricePerHour.toStringAsFixed(0)}/h',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // DESCRIPTION
                Text(
                  r.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                ),

                const SizedBox(height: 10),

                _infoRow(Icons.calendar_today, "Days", r.availableDays.join(', ')),
                _infoRow(Icons.access_time, "Time", r.availableTime),
                _infoRow(Icons.person_outline, "Owner", r.ownerName),

                const SizedBox(height: 12),

                // ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/booking',
                            arguments: {'resourceId': r.id, 'resourceName': r.name},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Book",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${r.name} added to cart.')),
                          );
                        },
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dark,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResourcesFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No resources found for \"$searchQuery\"",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: dark,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PostWishRequestScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Create Wish Request",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
