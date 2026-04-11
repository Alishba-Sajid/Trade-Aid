import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF0B2F2A), Color(0xFF119E90)],
);

const Color tealBackground = Color(0xFFE0F2F1);
const Color tealDark = Color(0xFF00695C);

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? product;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    final response = await supabase
        .from('product_full_view')
        .select()
        .eq('id', widget.productId)
        .single();

    setState(() {
      product = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tealBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                /// HEADER
                Container(
                  height: 70,
                  decoration: const BoxDecoration(gradient: appGradient),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Product Detail",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                /// BODY
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      children: [

                        /// 🔷 IMAGES
                        
                       Expanded(
  flex: 1,
  child: Container(
    height: 800,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: tealDark.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 3 / 4, // 🔥 ADJUST THIS (VERY IMPORTANT)
        child: Image.network(
          (product!['images'] != null && product!['images'].length > 0)
              ? product!['images'][0]
              : 'https://via.placeholder.com/300',
          fit: BoxFit.cover,
        ),
      ),
    ),
  ),
),
                        const SizedBox(width: 40),

                        /// 🔷 DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Text(
                                product!['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: tealDark,
                                ),
                              ),

                              const SizedBox(height: 10),
Text(
  "\$${product!['price'] ?? 0}",
  style: const TextStyle(fontSize: 25),
),

                              const SizedBox(height: 20),

                              Text(product!['description'] ?? '',
                              style: const TextStyle(fontSize: 25),),

                              const SizedBox(height: 20),

                              Text("Category: ${product!['category'] ?? ''}",style: const TextStyle(fontSize: 25)),
                              Text("Condition: ${product!['condition'] ?? ''}",style: const TextStyle(fontSize: 25)),
                              Text("Used Time: ${product!['used_time'] ?? ''}",style: const TextStyle(fontSize: 25)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}