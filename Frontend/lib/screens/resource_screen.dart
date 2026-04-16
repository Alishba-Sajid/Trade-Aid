import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'resources_detailed.dart';


class ResourceSharing extends StatefulWidget {
  const ResourceSharing({super.key});

  @override
  State<ResourceSharing> createState() => _ResourceSharingState();
}

class _ResourceSharingState extends State<ResourceSharing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();

  String selectedCommunity = "All";
  String searchQuery = "";
  List<String> communities = ["All"];
  List<Map<String, dynamic>> resources = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();

    fetchResources();
    fetchCommunities();
  }

  // Fetch resources from Supabase
  Future<void> fetchResources() async {
  try {
    final response = await supabase.from('resource_view').select();
    setState(() {
      resources = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  } catch (e) {
    debugPrint("ERROR fetching resources: $e");
    setState(() => isLoading = false);
  }
}

  // Fetch communities for dropdown
  Future<void> fetchCommunities() async {
    try {
      final response = await supabase.from('communities').select('name');
      final names = List<Map<String, dynamic>>.from(response)
          .map((e) => e['name'] as String)
          .toList();

      setState(() {
        communities = ["All", ...names];
      });
    } catch (e) {
      debugPrint("ERROR fetching communities: $e");
    }
  }

  // Filter resources by search query and selected community
  List<Map<String, dynamic>> get filteredResources {
    return resources.where((res) {
      final matchesSearch = res['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      final matchesCommunity = selectedCommunity == "All" ||
          res['community_id']?['name'] == selectedCommunity;
      return matchesSearch && matchesCommunity;
    }).toList();
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
                  top: 120 + 60 * sin((_controller.value * 2 * pi) + i.toDouble()),
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
                        "Resource Sharing",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔍 SEARCH + DROPDOWN
                      Row(
                        children: [
                          // Search Field
                          Expanded(
                            child: Container(
                              height: 45,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 238, 235, 235),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (val) =>
                                          setState(() => searchQuery = val),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Search resources",
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

                      // 📊 DATA TABLE
                      Expanded(
  child: isLoading
      ? const Center(child: CircularProgressIndicator())
      : Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.vertical, // ✅ Vertical scroll added
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // ✅ Horizontal scroll
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1400),
                child: DataTable(
                  columnSpacing: 60,
                  headingRowColor: WidgetStateProperty.resolveWith(
                    (_) => Colors.grey.shade100,
                  ),
                  columns: const [
                    DataColumn(
                        label: Text("Item Name",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Community",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Admin",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Posted By",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Rate",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Status",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Actions",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filteredResources.map((res) {
                    final status = res['is_enabled'] == true
                        ? "Available"
                        : "Disabled";

                    final communityName = res['community_name'] ?? 'N/A';
                    final posterName = res['poster_name'] ?? 'N/A';
                    final adminName = res['admin_name'] ?? 'N/A';

                    return DataRow(cells: [
                      DataCell(Text(res['name'] ?? '')),
                      DataCell(Text(communityName)),
                      DataCell(Text(adminName)),
                      DataCell(Text(posterName)),
                      DataCell(Text(res['rate']?.toString() ?? '0')),
                      DataCell(_statusBadge(status)),
                      DataCell(
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResourceDetailScreen(
                                  resourceId: res['id'],
                                ),
                              ),
                            );
                          },
                          child: const Text("View"),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
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

  // 🔽 COMMUNITY DROPDOWN
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
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => selectedCommunity = v!),
        ),
      ),
    );
  }

  // 🔽 STATUS BADGE
  Widget _statusBadge(String status) {
    final s = status.toLowerCase().trim();
    Color bg;
    String text;
    if (s == "available") {
      bg = Colors.green.shade100;
      text = "Available";
    } else if (s == "disabled") {
      bg = Colors.red.shade100;
      text = "Disabled";
    } else {
      bg = Colors.orange.shade100;
      text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}