// lib/screens/product_listing.dart
import 'package:flutter/material.dart';
import 'payment_option.dart';
import '../models/product.dart';
import '../models/cart.dart';

// 🎨 Shared color palette
const Color kPrimaryTeal = Color(0xFF004D40); // main teal used across the UI
const Color kLightTeal = Color(0xFF70B2B2); // lighter teal accent
const Color kSkyBlue = Color(0xFF9ECFD4); // soft blue used for placeholders

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String selectedCategory = 'Essential';
  String searchQuery = '';

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
  Widget build(BuildContext context) {
    final products = (productsByCategory[selectedCategory] ?? <Product>[])
        .where((product) =>
            product.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
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
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Category buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryButton('Essential'),
                  const SizedBox(width: 12),
                  _buildCategoryButton('Lifestyle'),
                ],
              ),
            ),

            // Product list
            Expanded(
              child: products.isEmpty
                  ? _buildNotFoundPane()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final p = products[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/product_details',
                                arguments: {'product': p},
                              );
                            },
                            child: _buildProductCard(context, p),
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

  Widget _buildProductCard(BuildContext context, Product p) {
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
            // Image with teal border
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: kPrimaryTeal, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  p.image,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: kSkyBlue,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported,
                          size: 40, color: Colors.white),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Right side
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    p.name,
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
                    p.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      height: 1.3,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Price and buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs ${p.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: kPrimaryTeal,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          // Buy button
                          SizedBox(
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PaymentSelectionScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryTeal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Buy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Add to cart
                          SizedBox(
                            height: 38,
                            width: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                Cart.instance.add(p);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: kPrimaryTeal,
                                    content: Text(
                                      '${p.name} added to cart. (${Cart.instance.itemCount})',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kLightTeal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(Icons.shopping_cart,
                                  color: Colors.white, size: 20),
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

  Widget _buildNotFoundPane() {
    final searchedText = searchQuery.trim();
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.search_off, size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        const Text('No products found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          searchedText.isEmpty
              ? 'Try a different search term.'
              : 'We couldn\'t find "$searchedText".',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: () {
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
            backgroundColor: kPrimaryTeal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ]),
    );
  }

  Widget _buildCategoryButton(String category) {
    final isSelected = selectedCategory == category;
    return ElevatedButton(
      onPressed: () => setState(() => selectedCategory = category),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isSelected ? kPrimaryTeal : kSkyBlue.withOpacity(0.5),
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(category),
    );
  }
}
