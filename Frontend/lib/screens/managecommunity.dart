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

  String selectedAdmin = 'All';
  String selectedMembers = 'All';

  final List<String> adminOptions = [
    'All',
    'Sana Zafar',
    'Nimrah Shoaib',
    'Zafar Ullah',
    'Shoukat Ali',
  ];

  final List<String> memberOptions = [
    'All',
    '50+',
    '100+',
    '150+',
    '200+',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // 🌊 Animated Background
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

              // ✨ Floating Circles
              ...List.generate(6, (i) {
                final size = 80.0 + i * 20;
                return Positioned(
                  left: (i * 120) % MediaQuery.of(context).size.width,
                  top: 100 +
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔍 Search + Dropdown Filters
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
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
                                        hintText: "Search communities",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Admin Dropdown
                          _buildDropdown(
                            value: selectedAdmin,
                            items: adminOptions,
                            onChanged: (v) =>
                                setState(() => selectedAdmin = v!),
                          ),
                          const SizedBox(width: 12),

                          // Members Dropdown
                          _buildDropdown(
                            value: selectedMembers,
                            items: memberOptions,
                            onChanged: (v) =>
                                setState(() => selectedMembers = v!),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 📊 Borderless Data Table
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(minWidth: 1400),
                            child: DataTable(
                              border: const TableBorder(), // ❌ No borders
                              columnSpacing: 70,
                              headingRowColor:
                                  WidgetStateColor.resolveWith(
                                      (_) => Colors.grey.shade100),
                              columns: const [
                                DataColumn(label: Text("Community ID")),
                                DataColumn(label: Text("Name")),
                                DataColumn(label: Text("Members")),
                                DataColumn(label: Text("Admin")),
                                DataColumn(label: Text("Total Items")),
                                DataColumn(
                                    label: Text("Total Beneficiaries")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: communityData.map((data) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(data["id"].toString())),
                                    DataCell(Text(data["name"].toString())),
                                    DataCell(
                                        Text(data["members"].toString())),
                                    DataCell(Text(data["admin"].toString())),
                                    DataCell(Text(data["items"].toString())),
                                    DataCell(Text(
                                        data["beneficiaries"].toString())),
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

  // 🔽 Reusable Dropdown Widget
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
