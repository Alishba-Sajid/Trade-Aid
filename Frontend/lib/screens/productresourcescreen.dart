import 'dart:math';
import 'productdetailed.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 👉 NEW: import resource detail screen
 

class ProductResource extends StatefulWidget {
  const ProductResource({super.key});

  @override
  State<ProductResource> createState() => _ProductResourceState();
}

class _ProductResourceState extends State<ProductResource>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();

  String selectedCommunity = "All";

  List<String> communities = ["All"];
  List<Map<String, dynamic>> products = [];

  /// ✅ NEW: resources
  List<Map<String, dynamic>> resources = [];

  bool isLoading = true;

  /// ✅ NEW: resource loading
  bool isResourceLoading = true;

  /// ✅ NEW: toggle
  bool isProductTab = true;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat();

    fetchProducts();
    fetchCommunities();

    /// ✅ NEW
    fetchResources();
  }

  Future<void> fetchProducts() async {
    try {
      final response =
          await supabase.from('product_dashboard').select();

      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  /// ✅ NEW FUNCTION
  Future<void> fetchResources() async {
  try {
    final response = await supabase
    .from('resources')
    .select('id, name, rate, description, available_days, images');
    setState(() {
      resources = List<Map<String, dynamic>>.from(response);
      isResourceLoading = false;
    });
  } catch (e) {
    debugPrint("RESOURCE ERROR: $e");
    setState(() => isResourceLoading = false);
  }
}

  Future<void> fetchCommunities() async {
    try {
      final response =
          await supabase.from('communities').select('name');

      final names = List<Map<String, dynamic>>.from(response)
          .map((e) => e['name'] as String)
          .toList();

      setState(() {
        communities = ["All", ...names];
      });
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              /// BACKGROUND
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.shade600,
                      Colors.teal.shade300,
                      Colors.cyan.shade200,
                    ],
                    stops: [
                      0.2,
                      0.6 + 0.2 * sin(_controller.value * pi * 2),
                      1.0,
                    ],
                  ),
                ),
              ),

              /// MAIN CARD
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Product & Resource Management",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// 🔥 NEW TOGGLE (Products / Resources)
                      

                      const SizedBox(height: 20),

                      /// EXISTING SEARCH + FILTER (UNCHANGED)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color:
                                    const Color.fromARGB(255, 238, 235, 235),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.search, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Search products",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _communityDropdown(),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// TABLE
                   Expanded(
  child: isLoading
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1400), // ✅ KEEP
            child: DataTable(
              columnSpacing: 70,
              headingRowColor: WidgetStateProperty.resolveWith(
                (_) => Colors.grey.shade100,
              ),
              columns: const [
                DataColumn(label: Text("Item Name")),
                DataColumn(label: Text("Community")),
                DataColumn(label: Text("Posted By")),
                DataColumn(label: Text("Price")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Actions")),
              ],
              rows: products.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item['title'] ?? '')),
                    DataCell(Text(item['community'] ?? '')),
                    DataCell(Text(item['posted_by'] ?? '')),
                    DataCell(Text(item['price']?.toString() ?? '0')),
                    DataCell(_statusBadge(item['status'] ?? '')),
                    DataCell(
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                productId: item['id'],
                              ),
                            ),
                          );
                        },
                        child: const Text("View"),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
)
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// DROPDOWN (UNCHANGED)
  Widget _communityDropdown() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCommunity,
          items: communities
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: (v) => setState(() => selectedCommunity = v!),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final s = status.toLowerCase().trim();

    Color bg;
    String text;

    if (s == "available") {
      bg = Colors.green.shade100;
      text = "Available";
    } else if (s == "pending") {
      bg = Colors.orange.shade100;
      text = "Pending";
    } else if (s == "sold") {
      bg = Colors.blue.shade100;
      text = "Sold";
    } else {
      bg = Colors.red.shade100;
      text = "Unavailable";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}