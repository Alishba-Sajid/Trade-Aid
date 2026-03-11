import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_details.dart';
import 'payment_option.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

// Your requested brand gradient
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color dark = Color(0xFF004D40);
const Color light = Color(0xFFF0F9F8);
const Color accent = Color(0xFF119E90);

class ProductListingScreen extends StatefulWidget {
  final String communityId;

  const ProductListingScreen({super.key, required this.communityId});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String selectedCategory = 'Essential';
  String searchQuery = '';
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  /* ================= FETCH PRODUCTS ================= */
Future<void> _fetchProducts() async {
  setState(() => isLoading = true);

  if (widget.communityId.isEmpty) {
    setState(() {
      products = [];
      isLoading = false;
    });
    return;
  }

  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) throw Exception("User not authenticated");

    // ---------------- CATEGORY + WISH FILTER ----------------
    PostgrestFilterBuilder query = supabase
        .from('products')
        .select()
        .eq('community_id', widget.communityId);

    if (selectedCategory != 'Wish Item') {
      // Essential / Lifestyle: show to all community members.
      // Include: (1) normal dashboard products (wish_request_id null), and
      // (2) wish-fulfillment products that became public after 48h.
      query = query.eq('category', selectedCategory).or(
        'wish_request_id.is.null,'
        'and(make_public_after_48h.eq.true,expires_at.lt.now())',
      );
    } else {
      // Wish Item tab: only products reserved for the current user (requester)
     query = query
    .not('wish_request_id', 'is', null)
    .gt('expires_at', DateTime.now().toIso8601String())
    .or('reserved_for.eq.${user.id},user_id.eq.${user.id}');
    }

    // ---------------- FETCH PRODUCTS ----------------
    final productResponse = await query;
    final productList = productResponse as List;

    if (productList.isEmpty) {
      setState(() {
        products = [];
        isLoading = false;
      });
      return;
    }

    // ---------------- FETCH SELLER PROFILES ----------------
    final userIds = productList
        .map((p) => p['user_id'] as String)
        .toSet()
        .toList();

    final profileResponse = await supabase
        .from('profiles')
        .select('user_id, full_name, address, profile_image_url')
        .inFilter('user_id', userIds); // only 2 args here

    final profileList = profileResponse as List;

    final profileMap = {for (var p in profileList) p['user_id']: p};

    // ---------------- MERGE PRODUCTS + PROFILE ----------------
    final List<Product> fetched = productList.map((json) {
      final map = json as Map<String, dynamic>;
      final profile = profileMap[map['user_id']];

      map['sellerName'] = profile?['full_name'];
      map['sellerAddress'] = profile?['address'];
      map['sellerProfileImageUrl'] = profile?['profile_image_url'];

      return Product.fromJson(map);
    }).toList();

    setState(() {
      products = fetched;
      isLoading = false;
    });
  } catch (e) {
    debugPrint("SUPABASE ERROR: $e");
    setState(() => isLoading = false);
  }
}
  /* ================= SEARCH FILTER ================= */

  List<Product> _filteredProducts() {
    return products
        .where((p) =>
            p.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  /* ================= UI BUILD ================= */

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts();

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
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: accent))
                : filtered.isEmpty
                    ? _buildNoProductsFound()
                    : Consumer<CartProvider>(
                        builder: (context, cart, _) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final product = filtered[index];
                              final isHeld = cart.isProductHeld(product.id);
                              final remaining =
                                  cart.remainingForProduct(product.id);

                              return _buildPremiumProductCard(
                                context,
                                product,
                                product.condition ?? 'Available',
                                product.usedTime ?? 'New',
                                product.sellerName ?? 'Community Member',
                                isHeld: isHeld,
                                remaining: remaining,
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /* ================= APP BAR ================= */

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

  /* ================= SEARCH ================= */

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

  /* ================= CATEGORIES ================= */

  Widget _buildCategorySelector() {
    final categories = ['Essential', 'Lifestyle', 'Wish Item'];

    return Row(
      children: categories
          .map((c) => Expanded(child: _buildCategoryButton(c)))
          .toList(),
    );
  }

  Widget _buildCategoryButton(String category) {
    final selected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => selectedCategory = category);
          _fetchProducts();
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            gradient: selected ? appGradient : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.white : dark,
            ),
          ),
        ),
      ),
    );
  }

  /* ================= PRODUCT CARD ================= */

  Widget _buildPremiumProductCard(
    BuildContext context,
    Product product,
    String condition,
    String usedTime,
    String sellerName, {
    required bool isHeld,
    required Duration remaining,
  }) {
    return StatefulBuilder(
      builder: (context, setCardState) {
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
              /// IMAGE + DOTS
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsScreen(product: product),
                      ),
                    ),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: PageView.builder(
                          itemCount: product.images.length,
                          onPageChanged: (index) {
                            setCardState(() {
                              product.currentPageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final image = product.images[index];
                            return image.startsWith('http')
                                ? Image.network(image, fit: BoxFit.cover)
                                : Image.asset(image, fit: BoxFit.cover);
                          },
                        ),
                      ),
                    ),
                  ),

                  if (product.images.length > 1)
                    Positioned(
                      bottom: 12,
                      child: Row(
                        children: List.generate(
                          product.images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width:
                                product.currentPageIndex == index ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: product.currentPageIndex == index
                                  ? appGradient
                                  : null,
                              color: product.currentPageIndex == index
                                  ? null
                                  : Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              /// TITLE + PRICE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 1,
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
                      color: accent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// DESCRIPTION
              Text(
                product.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              _infoRow(Icons.star_border, "Condition", condition),
              _infoRow(Icons.history, "Used", usedTime),
              _infoRow(Icons.person_outline, "Seller", sellerName),

              const SizedBox(height: 16),

              /// BUY BUTTON
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: appGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: isHeld
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const PaymentSelectionScreen()),
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text(
                          "Buy Now",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// CART
                  Container(
                    height: 48,
                    width: 55,
                    decoration: BoxDecoration(
                      gradient: isHeld ? null : appGradient,
                      color: isHeld ? Colors.grey : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: isHeld
                          ? null
                          : () {
                              context
                                  .read<CartProvider>()
                                  .addProduct(product);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product.name} added to cart'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );

                              Navigator.pushNamed(context, '/cart');
                            },
                      icon: const Icon(Icons.shopping_cart_outlined,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
                color: dark),
          ),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.poppins(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildNoProductsFound() {
    return Center(
      child: Text(
        "No products found",
        style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: dark),
      ),
    );
  }
}