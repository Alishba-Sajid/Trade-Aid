import 'package:flutter/material.dart';
import 'viewcommunitydetails.dart';

class ManageCommunityScreen extends StatelessWidget {
  const ManageCommunityScreen({super.key});

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
    {
      "id": "FL-2345",
      "name": "Miami Beach Group",
      "members": 100,
      "admin": "Areeba Mehmood",
      "items": 400,
      "beneficiaries": 250
    },
    {
      "id": "WA-6789",
      "name": "Block F",
      "members": 180,
      "admin": "Azmat Mir",
      "items": 650,
      "beneficiaries": 400
    },
    {
      "id": "IL-1234",
      "name": "Gulberg",
      "members": 230,
      "admin": "Mehmood ul Hassan",
      "items": 750,
      "beneficiaries": 500
    },
    {
      "id": "QA-5678",
      "name": "Korral",
      "members": 130,
      "admin": "Sibtuq Tul Ali",
      "items": 550,
      "beneficiaries": 320
    },
    {
      "id": "CO-9012",
      "name": "Dream Homes",
      "members": 160,
      "admin": "Nabeel Hashmi",
      "items": 480,
      "beneficiaries": 280
    },
    {
      "id": "AZ-3457",
      "name": "Alhannah",
      "members": 110,
      "admin": "Wajahat Qureshi",
      "items": 480,
      "beneficiaries": 280
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Material( // ✅ Added this line only
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Community Management",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 🔍 Search bar
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                
                
                borderRadius: BorderRadius.circular(8),
                
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Color.fromARGB(255, 170, 163, 163),),
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

            const SizedBox(height: 20),

            // 📊 Table
            // 📊 Community Management Table
Expanded(
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1500),
        child: DataTable(
          columnSpacing: 40,
          headingRowColor: WidgetStateColor.resolveWith(
              (states) => const Color(0xFFF3F4F6)),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
          dataTextStyle: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          columns: const [
            DataColumn(label: Text("Community ID")),
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("Members")),
            DataColumn(label: Text("Admin")),
            DataColumn(label: Text("Total Items")),
            DataColumn(label: Text("Total Beneficiaries")),
            DataColumn(label: Text("Actions")),
          ],
          rows: communityData.map((data) {
            return DataRow(
              cells: [
                DataCell(Text(data["id"].toString())),
                DataCell(Text(data["name"].toString())),
                DataCell(Text(data["members"].toString())),
                DataCell(Text(data["admin"].toString())),
                DataCell(Text(data["items"].toString())),
                DataCell(Text(data["beneficiaries"].toString())),
                DataCell(
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CommunityDetails(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      "View",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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
),

          ],
        ),
      ),
    ); // ✅ Material closes here
  }
}
