import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_profile.dart';

const Color dark = Color.fromARGB(255, 5, 1, 10);
const Color surface = Color(0xFFFFFFFF);
const Color subtleGrey = Color(0xFFF2F2F2);
const Color accentTeal = Color(0xFF119E90);

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final supabase = Supabase.instance.client;

  /// USERS FROM DATABASE
  List<Map<String, dynamic>> users = [];

  /// FILTER STATES
  String selectedUser = "All";
  String searchText = "";

  /// FETCH USERS FROM SUPABASE
  Future<void> fetchUsers() async {
    final response = await supabase.from('profiles').select();

    setState(() {
      users = List<Map<String, dynamic>>.from(response);
    });
  }

  List<String> get userNames =>
      ["All", ...users.map((u) => u["full_name"] ?? "").toSet()];

  /// FILTER LOGIC
  List<Map<String, dynamic>> get filteredUsers {
    return users.where((u) {
      final name = (u["full_name"] ?? "").toString();

      final matchesUser = selectedUser == "All" || name == selectedUser;

      final matchesSearch =
          name.toLowerCase().contains(searchText.toLowerCase());

      return matchesUser && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    fetchUsers();

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

                  /// SEARCH + DROPDOWN
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
                            fillColor:
                                const Color.fromARGB(255, 238, 235, 235),
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
                        onChanged: (v) => setState(() => selectedUser = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// DATA TABLE
            // ✅ Scrollable DataTable (vertical + horizontal)
// ✅ Scrollable DataTable (vertical + horizontal)
Expanded(
  child: users.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
          child: Column(
            children: [
              /// HEADER
              Container(
                color: subtleGrey,
                padding: const EdgeInsets.all(14),
                child: const Row(
                  children: [
                    Expanded(child: Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Gender", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Phone", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Address", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),

              /// DATA
              ...filteredUsers.map((user) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(user["full_name"] ?? "")),
                      Expanded(child: Text(user["gender"] ?? "")),
                      Expanded(child: Text(user["phone"] ?? "")),
                      Expanded(child: Text(user["address"] ?? "")),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            final userId = user['user_id'];
                            if (userId == null) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserProfile(
                                  userId: userId.toString(),
                                ),
                              ),
                            );
                          },
                          child: const Text("View"),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// DROPDOWN
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
}