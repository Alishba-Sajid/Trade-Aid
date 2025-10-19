import 'package:flutter/material.dart';
import '../models/product.dart';

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

  String safeString(dynamic Function() getter) {
    try {
      final v = getter();
      if (v == null) return 'N/A';
      return v.toString();
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = (productsByCategory[selectedCategory] ?? <Product>[])
        .where((product) => product.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Products', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildCategoryButton('Essential'),
            const SizedBox(width: 12),
            _buildCategoryButton('Lifestyle'),
          ]),
          const SizedBox(height: 20),

          // Product list
          if (products.isEmpty)
            Expanded(child: _buildNotFoundPane())
          else
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final condition = safeString(() => (product as dynamic).condition ?? 'Good');
                  final usedTime = safeString(() => (product as dynamic).usedTime ?? '2 months');
                  final sellerName = safeString(() => (product as dynamic).sellerName ?? 'Rahim Ali');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/product_details', arguments: {'product': product});
                      },
                      child: _buildVerticalProductCard(context, product, condition, usedTime, sellerName),
                    ),
                  );
                },
              ),
            ),
        ]),
      ),
    );
  }

  Widget _buildVerticalProductCard(BuildContext context, Product product, String condition, String usedTime, String sellerName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              product.image,
              width: 150,
              height: 170,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 150,
                height: 170,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Container(
                  margin: const EdgeInsets.only(top: 16), // ✅ Add top margin here
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Description (2 lines)
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, height: 1.3),
                ),
                const SizedBox(height: 8),

                // Condition and Used Time
                Row(
                  children: [
                    Expanded(
                      child: Text('Condition: $condition', style: const TextStyle(color: Colors.grey)),
                    ),
                    Text('Used: $usedTime', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),

                // Seller info (optional) - showing sellerName if present
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(sellerName, style: const TextStyle(fontSize: 13, color: Colors.black54))),
                  ],
                ),
                const SizedBox(height: 10),

                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Rs ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Buy pressed', style: TextStyle(color: Colors.black)),
                            backgroundColor: Colors.white,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text('Buy', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart', style: TextStyle(color: Colors.black)),
                            backgroundColor: Colors.white,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      child: const Icon(Icons.add_shopping_cart_outlined),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
