import 'package:flutter/material.dart';

class ResourceSharing extends StatefulWidget {
  const ResourceSharing({super.key});

  @override
  State<ResourceSharing> createState() => _ResourceSharingState();
}

class _ResourceSharingState extends State<ResourceSharing> {
  String selectedCommunity = "Select Community";

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
    {
      'name': '3D Printer',
      'community': 'Makerspace',
      'quantity': '1',
      'postedBy': 'Jessica Wong',
      'status': 'Disabled'
    },
    {
      'name': 'Sewing Machine',
      'community': 'Crafting Circle',
      'quantity': '2',
      'postedBy': 'David Kim',
      'status': 'Available'
    },
    {
      'name': 'Telescope',
      'community': 'Astronomy Society',
      'quantity': '1',
      'postedBy': 'Olivia Green',
      'status': 'In Use'
    },
    {
      'name': 'VR Headset',
      'community': 'Gaming Guild',
      'quantity': '4',
      'postedBy': 'Ethan Clark',
      'status': 'Available'
    },
    {
      'name': 'Drone',
      'community': 'Aerial Photography',
      'quantity': '1',
      'postedBy': 'Sophia White',
      'status': 'Disabled'
    },
    {
      'name': 'Projector',
      'community': 'Film Buffs',
      'quantity': '2',
      'postedBy': 'Noah Harris',
      'status': 'Available'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 30, 50, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Search Bar
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search",
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Dropdown Menu
          Container(
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCommunity,
                items: const [
                  DropdownMenuItem(
                      value: "Select Community",
                      child: Text("Select Community")),
                  DropdownMenuItem(
                      value: "Greenwood", child: Text("Greenwood")),
                  DropdownMenuItem(
                      value: "Willow Creek", child: Text("Willow Creek")),
                  DropdownMenuItem(value: "Oakwood", child: Text("Oakwood")),
                ],
                onChanged: (value) {
                  setState(() => selectedCommunity = value!);
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 🔹 Data Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1800),
                child: DataTable(
                  columnSpacing: 40,
                  headingRowColor: WidgetStateColor.resolveWith(
                    (states) => const Color(0xFFF3F4F6),
                  ),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  dataTextStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
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
                        DataCell(_statusBadge(resource["status"]!)),
                        DataCell(
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                            ),
                            child: const Text(
                              "View Details",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  // 🔹 Status Badge
  Widget _statusBadge(String status) {
    Color bgColor;
    if (status == "Available") {
      bgColor = const Color.fromARGB(255, 184, 221, 186);
    } else if (status == "In Use") {
      bgColor = const Color.fromARGB(255, 238, 200, 204);
    } else {
      bgColor = const Color.fromARGB(255, 238, 200, 204);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
