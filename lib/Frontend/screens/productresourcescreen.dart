import 'package:flutter/material.dart';

class ProductResource extends StatefulWidget {
  const ProductResource({super.key});

  @override
  State<ProductResource> createState() => _ProductResourceScreenState();
}

class _ProductResourceScreenState extends State<ProductResource> {
  String selectedCommunity = "Select Community";

  final List<Map<String, String>> products = [
    {
      'name': 'Laiba Soap',
      'community': 'Greenwood',
      'quantity': '50',
      'postedBy': 'Sophia Bennett',
      'status': 'Available'
    },
    {
      'name': 'Organic Honey',
      'community': 'Willow Creek',
      'quantity': '30',
      'postedBy': 'Ethan Carter',
      'status': 'Available'
    },
     {
      'name': 'Organic Honey',
      'community': 'Willow Creek',
      'quantity': '30',
      'postedBy': 'Ethan Carter',
      'status': 'Available'
    },
     {
      'name': 'Organic Honey',
      'community': 'Willow Creek',
      'quantity': '30',
      'postedBy': 'Ethan Carter',
      'status': 'Available'
    },
     {
      'name': 'Organic Honey',
      'community': 'Willow Creek',
      'quantity': '30',
      'postedBy': 'Ethan Carter',
      'status': 'Available'
    },
     {
      'name': 'Organic Honey',
      'community': 'Willow Creek',
      'quantity': '30',
      'postedBy': 'Ethan Carter',
      'status': 'Available'
    },
     {
      'name': 'Organic Honey',
      'community': 'Willow Creek',
      'quantity': '30',
      'postedBy': 'Ethan Carter',
      'status': 'Available'
    },
     {
      'name': 'Organic Honey',
      'community': 'Willow Creek',
      'quantity': '30',
      'postedBy': 'Ethan Carter',
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

          // 🔹 Dropdown
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

          const SizedBox(height: 20),

          // 🔹 Data Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1500),
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
                  rows: products.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item["name"]!)),
                        DataCell(Text(item["community"]!)),
                        DataCell(Text(item["quantity"]!)),
                        DataCell(Text(item["postedBy"]!)),
                        DataCell(_statusBadge(item["status"]!)),
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

  Widget _statusBadge(String status) {
    Color bgColor;
    if (status == "Available") {
      bgColor = const Color.fromARGB(255, 184, 221, 186);
    } else {
      bgColor = const Color.fromARGB(255, 238, 200, 204);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
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
