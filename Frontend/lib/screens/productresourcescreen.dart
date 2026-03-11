import 'dart:math';
import 'package:flutter/material.dart';

class ProductResource extends StatefulWidget {
  const ProductResource({super.key});

  @override
  State<ProductResource> createState() => _ProductResourceState();
}

class _ProductResourceState extends State<ProductResource>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String selectedCommunity = "All";

  final List<String> communities = [
    "All",
    "Greenwood",
    "Willow Creek",
    "Oakwood",
  ];

  final List<Map<String, String>> products = const [
    {
      'name': 'Laiba Soap',
      'community': 'Greenwood',
      'quantity': '50',
      'postedBy': 'Sophia Bennett',
      'status': 'Available',
    },
    {
      'name': 'Organic Honey',
      'community': 'Willow Creek',
      'quantity': '30',
      'postedBy': 'Ethan Carter',
      'status': 'Available',
    },
    {
      'name': 'Rice Bags',
      'community': 'Oakwood',
      'quantity': '80',
      'postedBy': 'Ayesha Khan',
      'status': 'Unavailable',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
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
              // 🌊 SAME ANIMATED GRADIENT BACKGROUND
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

              // ✨ FLOATING CIRCLES (same)
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
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                );
              }),

              // 📦 MAIN GLASS CARD (same layout)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
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

                      // 🔍 SEARCH + FILTER ROW (same alignment)
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

                      // 📊 DATA TABLE (same style)
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(minWidth: 1400),
                            child: DataTable(
                              columnSpacing: 70,
                              headingRowColor:
                                  WidgetStateColor.resolveWith(
                                      (_) => Colors.grey.shade100),
                              columns: const [
                                DataColumn(label: Text("Item Name")),
                                DataColumn(label: Text("Community")),
                                DataColumn(label: Text("Quantity")),
                                DataColumn(label: Text("Posted By")),
                                DataColumn(label: Text("Status")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: products.map((item) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(item['name']!)),
                                    DataCell(Text(item['community']!)),
                                    DataCell(Text(item['quantity']!)),
                                    DataCell(Text(item['postedBy']!)),
                                    DataCell(
                                        _statusBadge(item['status']!)),
                                    DataCell(
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          "View",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
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

  // 🔽 DROPDOWN (same look)
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
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => selectedCommunity = v!),
        ),
      ),
    );
  }

  // 🟢 STATUS BADGE
  Widget _statusBadge(String status) {
    final Color bg = status == "Available"
        ? Colors.green.shade100
        : Colors.red.shade100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
