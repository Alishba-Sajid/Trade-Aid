import 'dart:math';
import 'package:flutter/material.dart';
import 'user_profile.dart';

// 🌿 Premium Industrial Palette (UNCHANGED)
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
const Color accentTeal = Color(0xFF119E90);
const Color subtleGrey = Color(0xFFF2F2F2);

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// 🔹 DROPDOWN STATE
  String selectedStatus = "All";

  final List<String> statusOptions = [
    "All",
    "Active",
    "Suspended",
    "Banned",
  ];

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

  /// 🔹 FILTERED LIST
  List<Map<String, String>> get filteredUsers {
    if (selectedStatus == "All") return users;
    return users
        .where((u) => u["status"] == selectedStatus)
        .toList();
  }

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
              // 🌊 Animated Gradient Background
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
                      0.5 + 0.2 * sin(_controller.value * pi * 2),
                      1.0,
                    ],
                  ),
                ),
              ),

              // 📦 MAIN CARD
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 30, 40, 30),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(50, 40, 50, 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "User Management",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// 🔹 SEARCH + STATUS DROPDOWN
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search users",
                                prefixIcon: Icon(Icons.search,
                                    color: dark.withValues(alpha: 0.5)),
                                filled: true,
                                fillColor: surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: subtleGrey),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          _statusDropdown(),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// 🔹 TABLE (NOW FILTERED)
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor:
                                WidgetStateColor.resolveWith(
                                    (_) => subtleGrey),
                            columns: const [
                              DataColumn(label: Text("User")),
                              DataColumn(label: Text("Email")),
                              DataColumn(label: Text("Status")),
                              DataColumn(label: Text("Trust Score")),
                              DataColumn(label: Text("Joined")),
                              DataColumn(label: Text("Actions")),
                            ],
                            rows: filteredUsers.map((user) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(user["name"]!)),
                                  DataCell(Text(user["email"]!)),
                                  DataCell(_statusBadge(user["status"]!)),
                                  DataCell(Text("${user["trust"]}%")),
                                  DataCell(Text(user["joined"]!)),
                                  DataCell(
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                UserProfileScreen(user: user),
                                          ),
                                        );
                                      },
                                      child: const Text("View"),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
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

  /// 🔽 REAL DROPDOWN
  Widget _statusDropdown() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: subtleGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          items: statusOptions
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => selectedStatus = value!);
          },
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg = status == "Active"
        ? accent.withValues(alpha: 0.15)
        : status == "Suspended"
            ? Colors.orange.withValues(alpha: 0.18)
            : Colors.red.withValues(alpha: 0.18);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
