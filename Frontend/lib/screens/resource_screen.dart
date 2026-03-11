import 'package:flutter/material.dart';

class ResourceSharing extends StatefulWidget {
  const ResourceSharing({super.key});

  @override
  State<ResourceSharing> createState() => _ResourceSharingState();
}

class _ResourceSharingState extends State<ResourceSharing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String selectedCommunity = "All Communities";

  final List<Map<String, String>> resources = [
    {
      'name': 'Projector',
      'community': 'Tech Enthusiasts',
      'quantity': '2',
      'postedBy': 'Sarah Johnson',
      'status': 'Available'
    },
    {
      'name': 'Camera',
      'community': 'Photography Club',
      'quantity': '1',
      'postedBy': 'Daniel Lee',
      'status': 'In Use'
    },
    {
      'name': 'Microphone',
      'community': 'Music Lovers',
      'quantity': '4',
      'postedBy': 'Emily Chen',
      'status': 'Available'
    },
    {
      'name': 'Laptop',
      'community': 'Coding Group',
      'quantity': '5',
      'postedBy': 'Michael Brown',
      'status': 'Available'
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 14))
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
              /// 🌊 INDUSTRIAL BACKGROUND
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal.shade700,
                      Colors.teal.shade400,
                      Colors.cyan.shade200,
                    ],
                    stops: [
                      0.2,
                      0.5,
                      1.0,
                    ],
                  ),
                ),
              ),

              /// 📦 MAIN CARD
              Padding(
                padding: const EdgeInsets.all(30),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
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
                        "Resource Sharing",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// 🔍 SEARCH + DROPDOWN
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
                                        hintText: "Search resources",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          _communityDropdown(),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// 📊 DATA TABLE
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(minWidth: 1600),
                            child: DataTable(
                              columnSpacing: 60,
                              headingRowColor:
                                  WidgetStateColor.resolveWith(
                                      (_) => Colors.grey.shade100),
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              dataTextStyle: const TextStyle(fontSize: 15),
                              columns: const [
                                DataColumn(label: Text("Item Name")),
                                DataColumn(label: Text("Community")),
                                DataColumn(label: Text("Quantity")),
                                DataColumn(label: Text("Posted By")),
                                DataColumn(label: Text("Status")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: resources.map((resource) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(resource["name"]!)),
                                    DataCell(Text(resource["community"]!)),
                                    DataCell(Text(resource["quantity"]!)),
                                    DataCell(Text(resource["postedBy"]!)),
                                    DataCell(
                                        _statusBadge(resource["status"]!)),
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

  /// 🔽 COMMUNITY DROPDOWN
  Widget _communityDropdown() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCommunity,
          items: const [
            DropdownMenuItem(
                value: "All Communities", child: Text("All Communities")),
            DropdownMenuItem(
                value: "Tech Enthusiasts",
                child: Text("Tech Enthusiasts")),
            DropdownMenuItem(
                value: "Photography Club",
                child: Text("Photography Club")),
            DropdownMenuItem(
                value: "Coding Group", child: Text("Coding Group")),
          ],
          onChanged: (value) {
            setState(() => selectedCommunity = value!);
          },
        ),
      ),
    );
  }

  /// 🏷 STATUS BADGE
  Widget _statusBadge(String status) {
    Color bg = status == "Available"
        ? Colors.teal.withValues(alpha: 0.18)
        : status == "In Use"
            ? Colors.orange.withValues(alpha: 0.18)
            : Colors.red.withValues(alpha: 0.18);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}