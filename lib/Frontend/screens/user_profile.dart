
//User profile
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final Map<String, String> user;

  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔹 Header (Unchanged)
          Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 28),
                  child: Text(
                    "Trade&Aid",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    children: [
                      _navItem("Dashboard"),
                      _navItem("Users"),
                      _navItem("Community"),
                      _navItem("Reports"),
                      const SizedBox(width: 25),
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/profile.png'),
                        backgroundColor: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Title =====
                  const Text(
                    "User Profile",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Detailed view of user information and admin actions",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  const SizedBox(height: 40),

                  // ===== Profile Header =====
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 80,
                        backgroundImage: AssetImage('assets/new_avatar.png'),
                      ),
                      const SizedBox(width:40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Hassan Ali",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "User ID: 123456",
                          style: TextStyle(
                              fontSize: 18,
                              
                            ),
                          ),

                          Text(
                            "Joined: 2023-09-15",
                            style: TextStyle(
                              fontSize: 18,
                              
                            ),
                            
                            
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // ===== User Information Section (Horizontal Table Style) =====
                  sectionTitle("User Information"),
                  const SizedBox(height: 10),
                  buildTable(
                    [
                      "Email",
                      "Status",
                      "Trust Score",
                      "Last Login",
                      "Phone Number",
                      "Address"
                    ],
                    [
                      [
                        "hasanali@gmail.com",
                        "Active",
                        "8.5",
                        "2024-09-20 10:00 AM",
                        "+923698546932",
                        "123, Block 6, Gulberg"
                      ],
                    ],
                  ),

                  const SizedBox(height: 35),

                  // ===== Activity Log =====
                  sectionTitle("Activity Log"),
                  const SizedBox(height: 10),
                  buildTable(
                    ["Date", "Action", "Description"],
                    [
                      ["2024-09-20 10:00 AM", "Login", "User logged in successfully"],
                      ["2024-09-15 02:30 PM", "Transaction", "Purchase of item - \$25.00"],
                      ["2024-09-14 08:10 PM", "Community Interaction", "Posted a comment in the forum"],
                      ["2024-09-10 01:45 PM", "Account Update", "Updated profile information"],
                      ["2024-09-01 11:00 AM", "Account Creation", "Account created successfully"],
                    ],
                  ),

                  const SizedBox(height: 35),

                  // ===== Fraud History =====
                  sectionTitle("Fraud History"),
                  const SizedBox(height: 10),
                  buildTable(
                    ["Date", "Type", "Description", "Status"],
                    [
                      ["2023-07-10", "Suspicious Activity", "Multiple failed login attempts", "Flagged"],
                      ["2023-03-22", "Payment Fraud", "Disputed transaction", "Resolved"],
                      ["2023-01-15", "Account Takeover", "Unauthorized access detected", "Under Review"],
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text(
  "Admin Actions",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
),
const SizedBox(height: 20),

// 🔹 Buttons Row
Row(
  children: [
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      onPressed: () {},
      child: const Text(
        "Suspend user",
        style: TextStyle(color: Colors.white, fontSize: 16 ,fontWeight: FontWeight.bold),
      ),
    ),
    const SizedBox(width: 20),
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      onPressed: () {},
      child: const Text(
        "Ban user",
        style: TextStyle(color: Colors.black87, fontSize: 16 ,fontWeight: FontWeight.bold),
      ),
    ),
  ],
),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Header Nav Item
  static Widget _navItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // 🔹 Section Title
  static Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  // 🔹 Reusable Table Builder
 Widget buildTable(List<String> headers, List<List<String>> rows) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Table(
      border: TableBorder.symmetric(
        inside: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        // 🔹 Table Header Row
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
          children: headers
              .map(
                (header) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 18), // ⬆️ Increased row height
                  child: Text(
                    header,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
              .toList(),
        ),

        // 🔹 Table Data Rows
        ...rows.map(
          (row) => TableRow(
            decoration: const BoxDecoration(color: Colors.white),
            children: List.generate(row.length, (index) {
              final isStatusColumn = headers[index] == "Status";
              final cellText = row[index];

             if (isStatusColumn) {
  // 🎨 Grey rounded box for status values (centered text)
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
    child: Align(
      alignment: Alignment.center, // Center inside the table cell
      child: Container(
        width: 200, // 🔹 Controls box width (adjust between 70–100)
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          cellText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
} else {
  // Normal cell
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
    child: Text(
      cellText,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
    ),
  );
}

            }),
          ),
        ),
      ],
    ),
  );
  
}
}