import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_option.dart';
import 'post_wish_request.dart';
import '../models/product.dart';
import 'product_details.dart'; // new details screen

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

  Map<String, DateTime> cartTimers = {};
  Timer? countdownTimer;

  final Map<String, List<Product>> productsByCategory = {
    'Essential': [
      Product(
        id: 'p1',
        name: 'Vintage Leather Jacket',
        images: ['assets/jacket1.png', 'assets/jacket2.png'],
        price: 5000,
        description:
            'A stylish vintage leather jacket perfect for all seasons.',
        condition: 'Excellent',
        usedTime: 'New',
        sellerName: 'Community Member',
      ),
      Product(
        id: 'p2',
        name: 'Handmade Ceramic Vase',
        images: ['assets/vase1.png', 'assets/vase2.png', 'assets/vase3.png'],
        price: 1200,
        description: 'Beautiful ceramic vase made by local artisans.',
        condition: 'Good',
        usedTime: 'Used 1 month',
        sellerName: 'Artisan Shop',
      ),
      Product(
        id: 'p3',
        name: 'Tote Bag',
        images: ['assets/tote.png'],
        price: 1100,
        description: 'Durable cotton tote bag suitable for everyday use.',
        condition: 'Excellent',
        usedTime: 'New',
        sellerName: 'Community Member',
      ),
    ],
    'Lifestyle': [
      Product(
        id: 'p4',
        name: 'Yoga Mat',
        images: ['assets/yoga.jpg'],
        price: 2000,
        description: 'Non-slip yoga mat ideal for home workouts.',
        condition: 'New',
        usedTime: 'New',
        sellerName: 'Fitness Store',
      ),
      Product(
        id: 'p5',
        name: 'Aroma Candle Set',
        images: ['assets/candles.jpg'],
        price: 900,
        description: 'Set of 3 scented candles with relaxing aromas.',
        condition: 'New',
        usedTime: 'New',
        sellerName: 'Candle Shop',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
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
          Expanded(
            child: products.isEmpty
                ? _buildNoProductsFound()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isLocked =
                          cartTimers[product.id]?.isAfter(DateTime.now()) ??
                          false;
                      final remaining = isLocked
                          ? cartTimers[product.id]!.difference(DateTime.now())
                          : Duration.zero;

                      return _buildPremiumProductCard(
                        context,
                        product,
                        safeString(() => product.condition),
                        safeString(() => product.usedTime),
                        safeString(() => product.sellerName),
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
    final countdown =
        "${remaining.inMinutes.toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}";
    int currentImageIndex = 0;

    return GestureDetector(
      onTap: () {
        // Open product details page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
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
                        offset: Offset(0, 5),
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
                            itemCount: product.images.length,
                            onPageChanged: (index) {
                              setState(() {
                                currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.asset(
                                product.images[index],
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              );
                            },
                          ),
                        ),
                        if (product.images.length > 1)
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                product.images.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
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
                        product.name,
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
                      "Rs ${product.price}",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: accent.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // DESCRIPTION
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                _infoRow(Icons.star_border, "Condition", condition),
                _infoRow(Icons.history, "Used", usedTime),
                _infoRow(Icons.person_outline, "Seller", sellerName),
                const SizedBox(height: 12),
                // ACTION BUTTONS
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
                        color: isLocked ? Colors.grey : accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: isLocked
                            ? null
                            : () {
                                setState(() {
                                  cartTimers[product.id] = DateTime.now().add(
                                    const Duration(minutes: 5),
                                  );
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Added to cart"),
                                  ),
                                );
                              },
                        icon: isLocked
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.lock_outline,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    countdown,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Icon(
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
