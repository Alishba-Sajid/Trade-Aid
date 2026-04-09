import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ================= THEME =================
const Color backgroundLight = Color(0xFFF5F5F5);
const Color surface = Colors.white;

const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

// ================= MODEL =================
class DisputedProduct {
  final String id;
  final String productName;
  final String productPrice;
  final String buyerName;
  final String sellerName;
  final String imageUrl;
  String status;

  DisputedProduct({
    required this.id,
    required this.productName,
    required this.productPrice,
    required this.buyerName,
    required this.sellerName,
    required this.imageUrl,
    required this.status,
  });
}

// ================= SCREEN =================
class DisputedProductsScreen extends StatefulWidget {
  const DisputedProductsScreen({super.key});

  @override
  State<DisputedProductsScreen> createState() => _DisputedProductsScreenState();
}

class _DisputedProductsScreenState extends State<DisputedProductsScreen> {
  final supabase = Supabase.instance.client;

  List<DisputedProduct> _disputedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDisputedProducts();
  }

  Future<String> getUserName(String? userId) async {
    if (userId == null) return "Unknown";
    final res = await supabase
        .from('profiles')
        .select('full_name')
        .eq('user_id', userId)
        .maybeSingle();
    return res?['full_name'] ?? "Unknown";
  }

  Future<void> fetchDisputedProducts() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final community = await supabase
          .from('community_members')
          .select('community_id')
          .eq('user_id', userId)
          .eq('role', 'admin')
          .single();

      final communityId = community['community_id'];
      final response = await supabase
          .from('products')
          .select('id, title, price, status, images, user_id, reserved_for')
          .eq('status', 'disputed')
          .eq('community_id', communityId);

      List<DisputedProduct> tempList = [];
      for (var item in response) {
        final sellerName = await getUserName(item['user_id']);
        final buyerName = await getUserName(item['reserved_for']);

        tempList.add(
          DisputedProduct(
            id: item['id'],
            productName: item['title'],
            productPrice: "${item['price']}",
            sellerName: sellerName,
            buyerName: buyerName,
            imageUrl: (item['images'] != null && item['images'].isNotEmpty)
                ? item['images'][0]
                : '',
            status: item['status'] ?? 'disputed',
          ),
        );
      }

      setState(() {
        _disputedItems = tempList;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProductStatus(DisputedProduct product, String newStatus) async {
    try {
      await supabase
          .from('products')
          .update({'status': newStatus})
          .eq('id', product.id);

      setState(() {
        product.status = newStatus;
        _disputedItems.removeWhere((item) => item.id == product.id);
      });

      _showSnackBar(
        "${product.productName} marked as $newStatus",
        newStatus == 'sold' ? Colors.green : Colors.teal,
      );
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  // ================= UPDATED BORDER DIALOG =================
  void _handleResolve(DisputedProduct product) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(28),
              // THE CHEST/BORDER AT THE EDGE
              border: Border.all(
                color: const Color.fromARGB(255, 15, 119, 124),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.gavel_rounded, color: Colors.teal, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Resolve Dispute",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                    children: [
                      const TextSpan(text: "Resolving dispute for "),
                      TextSpan(
                        text: product.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      const TextSpan(text: ".\nChoose the final status of this item."),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Action Buttons
                _dialogButton(
                  label: "Resolve as Available",
                  isGradient: false,
                  onTap: () {
                    Navigator.pop(context);
                    _updateProductStatus(product, 'available');
                  },
                ),
                const SizedBox(height: 12),
                _dialogButton(
                  label: "Resolve as Sold",
                  isGradient: true,
                  onTap: () {
                    Navigator.pop(context);
                    _updateProductStatus(product, 'sold');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text("Disputed Products",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: appGradient)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _disputedItems.isEmpty
              ? const Center(child: Text("No disputed products found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _disputedItems.length,
                  itemBuilder: (context, index) {
                    final product = _disputedItems[index];
                    return _DisputeCard(
                      product: product,
                      onResolve: () => _handleResolve(product),
                    );
                  },
                ),
    );
  }

  Widget _dialogButton({
    required String label,
    required bool isGradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: isGradient ? appGradient : null,
          color: isGradient ? null : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isGradient ? null : Border.all(color: Colors.teal, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isGradient ? Colors.white : Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

// ================= CARD =================
class _DisputeCard extends StatelessWidget {
  final DisputedProduct product;
  final VoidCallback onResolve;

  const _DisputeCard({required this.product, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  product.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    _infoRow(Icons.person_outline, "Buyer: ", product.buyerName),
                    _infoRow(Icons.storefront_outlined, "Seller: ", product.sellerName),
                    _infoRow(Icons.sell_outlined, "Price: ", product.productPrice),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "DISPUTED",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              InkWell(
                onTap: onResolve,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: appGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Resolve",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.teal),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Expanded(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}