import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();

    fetchProducts();
    fetchCommunities();
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
              // 🌊 BACKGROUND
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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

              // ✨ FLOATING CIRCLES
              ...List.generate(6, (i) {
                final size = 80.0 + i * 20;
                return Positioned(
                  left: (i * 140) % MediaQuery.of(context).size.width,
                  top: 120 +
                      60 *
                          sin((_controller.value * 2 * pi) + i.toDouble()),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha:0.08),
                    ),
                  ),
                );
              }),

              // 📦 MAIN CARD
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.95),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
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

                      // 🔍 SEARCH + FILTER
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 238, 235, 235),
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

                      // 📊 TABLE
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(minWidth: 1300),
                                    child: DataTable(
                                      columnSpacing: 70,
                                      headingRowColor: WidgetStateProperty.resolveWith(
  (_) => Colors.grey.shade100,
),
                                      columns: const [
                                        DataColumn(label: Text("Item Name",style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text("Community",style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text("Posted By",style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text("Price",style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text("Status",style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text("Actions",style: TextStyle(fontWeight: FontWeight.bold))),
                                      ],
                                      rows: products.map((item) {
                                        // 🔍 DEBUG
                                        debugPrint("STATUS FROM DB: ${item['status']}");

                                        return DataRow(
                                          cells: [
                                            DataCell(Text(item['title'] ?? '')),
                                            DataCell(Text(item['community'] ?? '')),
                                            DataCell(Text(item['posted_by'] ?? '')),
                                            DataCell(Text(item['price']?.toString() ?? '0')),
                                            DataCell(_statusBadge(item['status']?.toString() ?? '')),
                                            DataCell(
                                              TextButton(
                                                onPressed: () {},
                                                child: const Text("View"),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                      ),
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

  // 🔽 DROPDOWN
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

  // ✅ FIXED STATUS BADGE
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