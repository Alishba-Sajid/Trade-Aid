import 'dart:math';
import 'package:flutter/material.dart';
import 'viewcommunitydetails.dart';

class ManageCommunityScreen extends StatefulWidget {
  const ManageCommunityScreen({super.key});

  @override
  State<ManageCommunityScreen> createState() => _ManageCommunityScreenState();
}

class _ManageCommunityScreenState extends State<ManageCommunityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String searchQuery = '';
  String selectedAdmin = 'All';

  final List<String> adminOptions = const [
    'All',
    'Sana Zafar',
    'Nimrah Shoaib',
    'Zafar Ullah',
    'Shoukat Ali',
  ];

  final List<Map<String, dynamic>> communityData = const [
    {
      "id": "KE-5247",
      "name": "Oakenwood Community",
      "members": 120,
      "admin": "Sana Zafar",
      "items": 500,
      "beneficiaries": 300
    },
    {
      "id": "CA-8912",
      "name": "Sunnyvale Residents",
      "members": 85,
      "admin": "Nimrah Shoaib",
      "items": 350,
      "beneficiaries": 200
    },
    {
      "id": "TX-3456",
      "name": "Airport Neighbors",
      "members": 200,
      "admin": "Zafar Ullah",
      "items": 700,
      "beneficiaries": 450
    },
    {
      "id": "NY-7890",
      "name": "Gulistan Locals",
      "members": 150,
      "admin": "Shoukat Ali",
      "items": 600,
      "beneficiaries": 350
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

  // ✅ SAFE FILTER LOGIC (NO WEB ERRORS)
  List<Map<String, dynamic>> get filteredCommunities {
    final query = searchQuery.trim().toLowerCase();

    return communityData.where((data) {
      final name = (data['name'] ?? '').toString().toLowerCase();
      final admin = (data['admin'] ?? '').toString().toLowerCase();
      final id = (data['id'] ?? '').toString().toLowerCase();

      final matchesSearch =
          query.isEmpty || name.contains(query) || admin.contains(query) || id.contains(query);

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
              // 🌊 Background
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

              // 📦 Main Card
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

                      // 🔍 Search + Admin Filter
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) =>
                                  setState(() => searchQuery = v),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText:
                                    "Search by community, admin, or ID",
                                filled: true,
                                 fillColor: const Color.fromARGB(255, 238, 235, 235),
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

                      // 📊 TABLE
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
                                DataColumn(label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Members", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Admin", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Items", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Beneficiaries", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filteredCommunities.map((data) {
                                return DataRow(cells: [
                                  DataCell(Text(data['id'].toString())),
                                  DataCell(Text(data['name'].toString())),
                                  DataCell(Text(data['members'].toString())),
                                  DataCell(Text(data['admin'].toString())),
                                  DataCell(Text(data['items'].toString())),
                                  DataCell(Text(data['beneficiaries'].toString())),
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
                                      child: const Text(
                                        "View",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ]);
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