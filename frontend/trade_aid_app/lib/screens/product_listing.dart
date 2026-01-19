import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_option.dart';
import 'post_wish_request.dart';
import '../models/product.dart';

// 🌿 Premium Color Constants
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Color dark = Color(0xFF004D40);
const Color light = Color(0xFFF0F9F8);
const Color accent = Color(0xFF119E90);

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String selectedCategory = 'Essential';
  String searchQuery = '';

  // Track product lock for 5 minutes when added to cart
  Map<String, DateTime> cartTimers = {}; // productId -> unlock time
  Timer? countdownTimer;

  final Map<String, List<Product>> productsByCategory = {
    'Essential': [
      Product(
        id: 'p1',
        name: 'Vintage Leather Jacket',
        image: 'assets/jacket.jpg',
        price: 5000,
        description: 'A stylish vintage leather jacket perfect for all seasons.',
      ),
      Product(
        id: 'p2',
        name: 'Handmade Ceramic Vase',
        image: 'assets/vase.jpg',
        price: 1200,
        description: 'Beautiful ceramic vase made by local artisans.',
      ),
      Product(
        id: 'p3',
        name: 'Tote Bag',
        image: 'assets/tote.jpg',
        price: 1100,
        description: 'Durable cotton tote bag suitable for everyday use.',
      ),
    ],
    'Lifestyle': [
      Product(
        id: 'p4',
        name: 'Yoga Mat',
        image: 'assets/yoga.jpg',
        price: 2000,
        description: 'Non-slip yoga mat ideal for home workouts.',
      ),
      Product(
        id: 'p5',
        name: 'Aroma Candle Set',
        image: 'assets/candles.jpg',
        price: 900,
        description: 'Set of 3 scented candles with relaxing aromas.',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {}); // refresh countdowns every second
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  String safeString(dynamic Function() getter) {
    try {
      final value = getter();
      return value?.toString() ?? 'N/A';
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = (productsByCategory[selectedCategory] ?? [])
        .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: light,
      body: Column(
        children: [
          _buildPremiumAppBar(context),
          // Sticky search bar and category buttons
          Container(
            color: light,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildCategorySelector(),
              ],
            ),
          ),
          // Scrollable product list
          Expanded(
            child: products.isEmpty
                ? _buildNoProductsFound()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isLocked = cartTimers[product.id]?.isAfter(DateTime.now()) ?? false;
                      final remaining = isLocked
                          ? cartTimers[product.id]!.difference(DateTime.now())
                          : Duration.zero;

                      return _buildPremiumProductCard(
                        context,
                        product,
                        safeString(() => (product as dynamic).condition ?? 'Excellent'),
                        safeString(() => (product as dynamic).usedTime ?? 'New'),
                        safeString(() => (product as dynamic).sellerName ?? 'Community Member'),
                        isLocked,
                        remaining,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAppBar(BuildContext context) {
    return Container(
      height: 130,
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
                "Products",
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
        hintText: 'Search products',
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

  Widget _buildCategorySelector() {
    return Row(
      children: [
        Expanded(child: _buildCategoryButton('Essential')),
        const SizedBox(width: 12),
        Expanded(child: _buildCategoryButton('Lifestyle')),
      ],
    );
  }

  Widget _buildCategoryButton(String category) {
    final selected = selectedCategory == category;
    return ElevatedButton(
      onPressed: () => setState(() => selectedCategory = category),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? accent : Colors.white,
        foregroundColor: selected ? Colors.white : dark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(category),
    );
  }

  Widget _buildPremiumProductCard(
    BuildContext context,
    Product product,
    String condition,
    String usedTime,
    String sellerName,
    bool isLocked,
    Duration remaining,
  ) {
    String countdown = "${remaining.inMinutes.toString().padLeft(2,'0')}:${(remaining.inSeconds % 60).toString().padLeft(2,'0')}";

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product_details', arguments: {'product': product});
      },
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                product.image,
                width: 120,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: dark,
                          ),
                        ),
                      ),
                      Text(
                        "Rs ${product.price}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.star_border, "Condition", condition),
                  _infoRow(Icons.history, "Used", usedTime),
                  _infoRow(Icons.person_outline, "Seller", sellerName),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PaymentSelectionScreen(),
                              ),
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
                            "Buy Now",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: isLocked ? Colors.grey : dark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: isLocked
                              ? null
                              : () {
                                  setState(() {
                                    cartTimers[product.id] =
                                        DateTime.now().add(const Duration(minutes: 5));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Added to cart")),
                                    );
                                  });
                                },
                          icon: isLocked
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(Icons.lock_outline, color: Colors.white),
                                    Text(
                                      countdown,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                        ),
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

  Widget _buildNoProductsFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No product found for \"$searchQuery\"",
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
                  MaterialPageRoute(builder: (_) => const PostWishRequestScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
