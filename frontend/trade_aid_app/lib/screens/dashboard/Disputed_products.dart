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
  State<DisputedProductsScreen> createState() =>
      _DisputedProductsScreenState();
}

class _DisputedProductsScreenState
    extends State<DisputedProductsScreen> {
  final supabase = Supabase.instance.client;

  List<DisputedProduct> _disputedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDisputedProducts();
  }

  // ================= GET USER NAME =================
  Future<String> getUserName(String? userId) async {
    if (userId == null) return "Unknown";

    final res = await supabase
        .from('profiles')
        .select('full_name')
        .eq('user_id', userId)
        .maybeSingle();

    return res?['full_name'] ?? "Unknown";
  }

  // ================= FETCH DISPUTED PRODUCTS =================
  Future<void> fetchDisputedProducts() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      // 1️⃣ Get admin's community
      final community = await supabase
          .from('community_members')
          .select('community_id')
          .eq('user_id', userId)
          .eq('role', 'admin')
          .single();

      final communityId = community['community_id'];

      // 2️⃣ Get disputed products of THAT community
      final response = await supabase
          .from('products')
          .select(
              'id, title, price, status, images, user_id, reserved_for')
          .eq('status', 'disputed')
          .eq('community_id', communityId);

      List<DisputedProduct> tempList = [];

      // 3️⃣ Fetch seller & buyer names manually (SAFE)
      for (var item in response) {
        final sellerName = await getUserName(item['user_id']);
        final buyerName = await getUserName(item['reserved_for']);

        tempList.add(
          DisputedProduct(
            id: item['id'],
            productName: item['title'],
            productPrice: "\$${item['price']}",
            sellerName: sellerName,
            buyerName: buyerName,
            imageUrl: (item['images'] != null &&
                    item['images'].isNotEmpty)
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
      print("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= UPDATE STATUS =================
  Future<void> _updateProductStatus(
      DisputedProduct product, String newStatus) async {
    try {
      await supabase
          .from('products')
          .update({'status': newStatus})
          .eq('id', product.id);

      setState(() {
        product.status = newStatus;
      });

      _showSnackBar(
        "${product.productName} marked as $newStatus",
        newStatus == 'sold' ? Colors.green : Colors.teal,
      );
    } catch (e) {
      print("Update Error: $e");
    }
  }

  // ================= RESOLVE =================
  void _handleResolve(DisputedProduct product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text("Resolve Dispute",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Product: ${product.productName}",
                  style:
                      const TextStyle(fontWeight: FontWeight.w600)),
              Text("Price: ${product.productPrice}"),
              Text("Buyer: ${product.buyerName}"),
              const SizedBox(height: 20),
              const Text(
                  "How would you like to resolve this dispute?"),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          actions: [
            _dialogButton(
              label: "Resolve as Available",
              isGradient: false,
              onTap: () async {
                Navigator.pop(context);
                await _updateProductStatus(product, 'available');
              },
            ),
            const SizedBox(height: 8),
            _dialogButton(
              label: "Resolve as Sold",
              isGradient: true,
              onTap: () async {
                Navigator.pop(context);
                await _updateProductStatus(product, 'sold');
              },
            ),
          ],
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text("Disputed Products",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: appGradient)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _disputedItems.length,
              itemBuilder: (context, index) {
                final product = _disputedItems[index];
                return _DisputeCard(
                  product: product,
                  onResolve: () =>
                      _handleResolve(product),
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
        padding:
            const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isGradient ? appGradient : null,
          color: isGradient ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isGradient
              ? null
              : Border.all(color: Colors.teal, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color:
                  isGradient ? Colors.white : Colors.teal,
              fontWeight: FontWeight.bold,
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

  const _DisputeCard({
    required this.product,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(product.productName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    const SizedBox(height: 4),
                    _infoRow(Icons.person,
                        "Buyer: ", product.buyerName),
                    _infoRow(Icons.store,
                        "Seller: ", product.sellerName),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text("Status: ${product.status}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: product.status ==
                            'disputed'
                        ? Colors.orange
                        : Colors.blueGrey,
                  )),
              InkWell(
                onTap: onResolve,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: appGradient,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Text("Resolve",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoRow(
      IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.teal),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}