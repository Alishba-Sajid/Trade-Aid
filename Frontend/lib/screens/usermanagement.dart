import 'dart:math';
import 'package:flutter/material.dart';
import 'user_profile.dart';

const Color dark = Color(0xFF0B2F2A);
const Color surface = Color(0xFFFFFFFF);
const Color subtleGrey = Color(0xFFF2F2F2);
const Color accent = Color(0xFF119E90);

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// 🔹 FILTER STATES
  String selectedStatus = "All";
  String selectedUser = "All";
  String searchText = "";

  /// 🔹 DROPDOWN OPTIONS
  final List<String> statusOptions = ["All", "Active", "Suspended", "Banned"];

  final List<Map<String, String>> users = [
    {"name": "Yousaf Ali", "email": "yousaf78@gmail.com", "status": "Active", "trust": "85", "joined": "2023-01-10"},
    {"name": "Sana Mr", "email": "sanamr@gmail.com", "status": "Active", "trust": "92", "joined": "2023-02-20"},
    {"name": "Hassan Ali", "email": "hassan1@gmail.com", "status": "Suspended", "trust": "45", "joined": "2023-03-05"},
    {"name": "Zara Ahmed", "email": "ahmed.zara@gmail.com", "status": "Active", "trust": "78", "joined": "2023-04-09"},
    {"name": "Gul Hameed", "email": "hameed45@gmail.com", "status": "Banned", "trust": "20", "joined": "2023-05-22"},
  ];

  List<String> get userNames =>
      ["All", ...users.map((u) => u["name"]!).toSet()];

  /// 🔹 CORRECT FILTER LOGIC
  List<Map<String, String>> get filteredUsers {
    return users.where((u) {
      final matchesStatus =
          selectedStatus == "All" || u["status"] == selectedStatus;

      final matchesUser =
          selectedUser == "All" || u["name"] == selectedUser;

      final matchesSearch = u["name"]!
          .toLowerCase()
          .contains(searchText.toLowerCase());

      return matchesStatus && matchesUser && matchesSearch;
    }).toList();
  }

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
          return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal.shade700,
                  Colors.teal.shade300,
                ],
                stops: [
                  0.3,
                  0.7 + 0.2 * sin(_controller.value * pi * 2),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "User Management",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: dark),
                  ),
                  const SizedBox(height: 20),

                  /// 🔍 SEARCH + DROPDOWNS
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() => searchText = value);
                          },
                          decoration: InputDecoration(
                            hintText: "Search by user name",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 238, 235, 235),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      _dropdown(
                        value: selectedUser,
                        items: userNames,
                        onChanged: (v) =>
                            setState(() => selectedUser = v),
                      ),
                      const SizedBox(width: 15),
                      _dropdown(
                        value: selectedStatus,
                        items: statusOptions,
                        onChanged: (v) =>
                            setState(() => selectedStatus = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// 📊 TABLE
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 1400),
                        child: DataTable(
                          headingRowColor:
                              WidgetStateProperty.all(subtleGrey),
                          columnSpacing: 50,
                          columns: const [
                            DataColumn(label: Text("id", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("user_id", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("full_name", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("gender", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("phone", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("address", style: TextStyle(fontWeight: FontWeight.bold))),
                            

                          ],
                          rows: filteredUsers.map((user) {
                            return DataRow(cells: [
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
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔽 REUSABLE DROPDOWN
  Widget _dropdown({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: subtleGrey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg = status == "Active"
        ? accent.withValues(alpha: 0.2 )
        : status == "Suspended"
            ? Colors.orange.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}