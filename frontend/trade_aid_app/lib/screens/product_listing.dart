// lib/screens/product_listing.dart
import 'package:flutter/material.dart';
import 'payment_option.dart'; // keep this import (navigation preserved)
import '../models/product.dart';
import '../models/cart.dart'; // new: use the in-memory cart singleton

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

    final bottomSafePadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryButton('Essential'),
                  const SizedBox(width: 12),
                  _buildCategoryButton('Lifestyle'),
                ],
              ),
              const SizedBox(height: 20),
              if (products.isEmpty)
                Expanded(child: _buildNotFoundPane())
              else
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 16 + bottomSafePadding),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            // tap whole card -> open product details
                            Navigator.pushNamed(
                              context,
                              '/product_details',
                              arguments: {'product': product},
                            );
                          },
                          child: _buildProductRowCard(context, product, product.price),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductRowCard(BuildContext context, Product product, num price) {
    return Container(
      height: 160, // increased card height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          // Image on left
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            child: Image.asset(
              product.image,
              width: 130,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 130,
                height: 160,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 36, color: Colors.grey),
              ),
            ),
          ),

          // Right side - content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.2),
                  ),

                  const Spacer(),

                  // Bottom row: Price + Buy + Cart (same line)
                  Row(
                    children: [
                      // Price on left
                      Text(
                        'Rs ${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),

                      // Buy button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PaymentSelectionScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F9D58),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          elevation: 0,
                        ),
                        child: const Text('Buy', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),

                      const SizedBox(width: 8),

                      // Cart button: add to in-memory cart and show snackbar
                      SizedBox(
                        height: 38,
                        width: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Cart.instance.add(product);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart. (${Cart.instance.itemCount})'),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A84FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => searchQuery = ''),
              child: const Icon(Icons.close, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // ✅ Updated "No items found" pane with Create Wish Request button (no navigation)
  Widget _buildNotFoundPane() {
    final searchedText = searchQuery.trim();
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.search_off, size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        const Text('No items found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          searchedText.isEmpty ? 'Try a different search term.' : 'We couldn\'t find "$searchedText".',
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
            backgroundColor: const Color(0xFF004D40),
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
        backgroundColor: isSelected ? Colors.black : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(category),
    );
  }
}
