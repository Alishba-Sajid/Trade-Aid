import 'package:flutter/material.dart';
import 'user_profile.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<Map<String, String>> users = [
    {"name": "Yousaf Ali", "email": "yousaf78@gmail.com", "status": "Active", "trust": "85", "joined": "2023-01-10"},
    {"name": "Sana Mr", "email": "sanamr@gmail.com", "status": "Active", "trust": "92", "joined": "2023-02-20"},
    {"name": "Hassan Ali", "email": "hassan1@gmail.com", "status": "Suspended", "trust": "45", "joined": "2023-03-05"},
    {"name": "Zara Ahmed", "email": "ahmed.zara@gmail.com", "status": "Active", "trust": "78", "joined": "2023-04-09"},
    {"name": "Gul Hameed", "email": "hameed45@gmail.com", "status": "Banned", "trust": "20", "joined": "2023-05-22"},
    {"name": "Rabia Hassan", "email": "rabiy78@gmail.com", "status": "Active", "trust": "88", "joined": "2023-06-15"},
    {"name": "Sibgha Shirazi", "email": "grayshades@gmail.com", "status": "Active", "trust": "70", "joined": "2023-07-20"},
    {"name": "Ehsan Ullah", "email": "ehsanullah@gmail.com", "status": "Suspended", "trust": "55", "joined": "2023-08-25"},
    {"name": "Saro Hanif", "email": "sarohanif78@gmail.com", "status": "Active", "trust": "90", "joined": "2023-09-10"},
    {"name": "Sariya Mumtaz", "email": "smumtaz45@gmail.com", "status": "Active", "trust": "80", "joined": "2023-10-10"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50, 40, 50, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Page Header
            const Text(
              "User Management",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Manage all users of the application",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 30),

            // 🔹 Search Bar + Filters Row
            Row(
              children: [
                // Search Box
                Expanded(
                  flex: 2,
                  
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search users by name, email, or ID",
                      prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 196, 192, 192)),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 245, 245, 245),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                  
                        borderSide: const BorderSide(color: Color.fromARGB(255, 241, 239, 239)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                _filterDropdown("Status"),
                const SizedBox(width: 20),
                _filterDropdown("Trust Score"),
                const SizedBox(width: 20),
                _filterDropdown("Joined"),
              ],
            ),
            const SizedBox(height: 25),

            // 🔹 Table Container (like Community Management)
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
                        DataColumn(label: Text("User")),
                        DataColumn(label: Text("Email")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Trust Score")),
                        DataColumn(label: Text("Joined")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: users.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user["name"]!)),
                            DataCell(Text(user["email"]!)),
                            DataCell(_statusBadge(user["status"]!)),
                            DataCell(Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    value: double.parse(user["trust"]!) / 100,
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text("${user["trust"]!}%"),
                              ],
                            )),
                            DataCell(Text(user["joined"]!)),
                            DataCell(
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserProfileScreen(user: user),
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
    );
  }

  // 🔹 Filter dropdown widget
  Widget _filterDropdown(String title) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 245, 245),
        border: Border.all(color: const Color.fromARGB(255, 219, 218, 218)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Icon(Icons.arrow_drop_down, color: Colors.black54),
        ],
      ),
    );
  }

  // 🔹 Status badge
  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case "Active":
        color = const Color.fromARGB(255, 148, 150, 148).withValues(alpha: 0.15);

        break;
      case "Suspended":
          color = const Color.fromARGB(255, 148, 150, 148).withValues(alpha: 0.15);

        break;
      case "Banned":
             color = const Color.fromARGB(255, 148, 150, 148).withValues(alpha: 0.15);

        break;
      default:
             color = const Color.fromARGB(255, 148, 150, 148).withValues(alpha: 0.15);

    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
