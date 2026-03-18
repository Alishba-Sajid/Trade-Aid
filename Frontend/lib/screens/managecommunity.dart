import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'viewcommunitydetails.dart';

class ManageCommunityScreen extends StatefulWidget {
  const ManageCommunityScreen({super.key});

  @override
  State<ManageCommunityScreen> createState() =>
      _ManageCommunityScreenState();
}

class _ManageCommunityScreenState extends State<ManageCommunityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final supabase = Supabase.instance.client;

  String searchQuery = '';
  String selectedAdmin = 'All';

  List<Map<String, dynamic>> communityData = [];

  /// 🔥 FETCH DATA
  Future<void> fetchCommunities() async {
    final response =
        await supabase.from('community_management').select();

    setState(() {
      communityData = List<Map<String, dynamic>>.from(response);
    });
  }

  /// 🔽 ADMIN FILTER LIST
  List<String> get adminOptions {
    final admins =
        communityData.map((e) => e['admin'].toString()).toSet();
    return ['All', ...admins];
  }

  @override
  void initState() {
    super.initState();

    fetchCommunities();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🔍 FILTER LOGIC
  List<Map<String, dynamic>> get filteredCommunities {
    final query = searchQuery.trim().toLowerCase();

    return communityData.where((data) {
      final name = (data['name'] ?? '').toString().toLowerCase();
      final admin = (data['admin'] ?? '').toString().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
              name.contains(query) ||
              admin.contains(query);

      final matchesAdmin =
          selectedAdmin == 'All' || data['admin'] == selectedAdmin;

      return matchesSearch && matchesAdmin;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              /// 🌊 Background
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

              /// 📦 MAIN CARD
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
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Community Management",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      /// 🔍 SEARCH + FILTER
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) =>
                                  setState(() => searchQuery = v),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText:
                                    "Search by community or admin",
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 238, 235, 235),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildDropdown(),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// 📊 TABLE (SCROLL FIXED)
                      Expanded(
                        child: communityData.isEmpty
                            ? const Center(
                                child: CircularProgressIndicator())
                            : SingleChildScrollView( // ✅ vertical
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal, // ✅ horizontal
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(minWidth: 1400),
                                    child: DataTable(
                                      columnSpacing: 70,
                                      headingRowColor:
                                          WidgetStateColor.resolveWith(
                                              (_) =>
                                                  Colors.grey.shade100),
                                      columns: const [
                                        DataColumn(label: Text("Name",style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text("Members",style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text("Admin",style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text("Items",style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                        DataColumn(
                                            label: Text("Beneficiaries",style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text("Actions", style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                      ],
                                      rows: filteredCommunities.map((data) {
                                        return DataRow(cells: [
                                          DataCell(
                                              Text(data['name'].toString())),
                                          DataCell(Text(
                                              data['members'].toString())),
                                          DataCell(
                                              Text(data['admin'].toString())),
                                          DataCell(
                                              Text(data['items'].toString())),
                                          DataCell(Text(data['beneficiaries']
                                              .toString())),
                                          DataCell(
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const CommunityDetails(),
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

  /// 🔽 DROPDOWN
  Widget _buildDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedAdmin,
        items: adminOptions
            .map((e) =>
                DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => selectedAdmin = v!),
      ),
    );
  }
}