import 'package:flutter/material.dart';

/// 🌿 Premium Industrial Palette
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color dark = Color(0xFF0B2F2A);
const Color light = Color(0xFFF4FAF9);
const Color accent = Color(0xFF119E90);
const Color surface = Color(0xFFFFFFFF);
const Color darkPrimary = Color(0xFF004D40);
const Color backgroundLight = Color(0xFFF8FAFA);
const Color subtleGrey = Color(0xFFF2F2F2);

class UserProfileScreen extends StatelessWidget {
  final Map<String, String> user;

  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Column(
        children: [
          // 🔹 HEADER
          Container(
            height: 70,
            decoration: const BoxDecoration(gradient: appGradient),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Trade&Aid",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                CircleAvatar(
                  radius: 26,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
              ],
            ),
          ),

          // 🔹 BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(60, 40, 60, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "User Profile",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: dark,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🔹 PROFILE CARD
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 70,
                          backgroundImage:
                              AssetImage('assets/new_avatar.png'),
                        ),
                        const SizedBox(width: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Hassan Ali",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: darkPrimary,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text("User ID: 123456"),
                            Text("Joined: 2023-09-15"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  sectionTitle("User Information"),
                  const SizedBox(height: 12),
                  buildTable(
                    ["Email", "Status", "Trust", "Last Login", "Phone", "Address"],
                    [
                      [
                        "hasanali@gmail.com",
                        "Active",
                        "85%",
                        "2024-09-20 10:00 AM",
                        "+923698546932",
                        "Gulberg, Lahore"
                      ]
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ✅ ACTIVITY LOG TABLE
                  sectionTitle("Activity Log"),
                  const SizedBox(height: 12),
                  buildTable(
                    ["Date", "Activity", "IP Address", "Result"],
                    [
                      [
                        "2024-09-18",
                        "Login Attempt",
                        "192.168.1.10",
                        "Success"
                      ],
                      [
                        "2024-09-17",
                        "Password Change",
                        "192.168.1.15",
                        "Success"
                      ],
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ✅ FRAUD HISTORY TABLE
                  sectionTitle("Fraud History"),
                  const SizedBox(height: 12),
                  buildTable(
                    ["Date", "Issue", "Severity", "Status"],
                    [
                      [
                        "2024-08-01",
                        "Multiple failed logins",
                        "Medium",
                        "Resolved"
                      ],
                      [
                        "2024-07-15",
                        "Suspicious transaction",
                        "High",
                        "Flagged"
                      ],
                    ],
                  ),

                  const SizedBox(height: 40),

                  sectionTitle("Admin Actions"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Suspend User",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          side: const BorderSide(color: darkPrimary),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Ban User",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkPrimary,
                          ),
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

  // 🔹 SECTION TITLE
  static Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: dark,
      ),
    );
  }

  // 🔹 INDUSTRIAL TABLE
  Widget buildTable(List<String> headers, List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: subtleGrey),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: subtleGrey),
            children: headers
                .map(
                  (h) => Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      h,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          ...rows.map(
            (row) => TableRow(
              children: row
                  .map(
                    (cell) => Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(cell),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
