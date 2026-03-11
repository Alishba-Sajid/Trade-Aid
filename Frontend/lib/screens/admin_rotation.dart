import 'dart:math';
import 'package:flutter/material.dart';

const Color dark = Color(0xFF0B2F2A);
const Color surface = Color(0xFFFFFFFF);
const Color subtleGrey = Color(0xFFF2F2F2);
const Color accent = Color(0xFF119E90);

class AdminRotationScreen extends StatefulWidget {
  const AdminRotationScreen({super.key});

  @override
  State<AdminRotationScreen> createState() => _AdminRotationScreenState();
}

class _AdminRotationScreenState extends State<AdminRotationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> rotationData = [
    {"community": "Tech Enthusiasts Group", "status": "Active", "progress": 75},
    {"community": "Local Book Club", "status": "Pending", "progress": 0},
    {"community": "Photography Club", "status": "Completed", "progress": 100},
    {"community": "Gardens", "status": "Pending", "progress": 40},
  ];

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

  Color statusColor(String status) {
    switch (status) {
      case "Active":
        return accent;
      case "Pending":
        return Colors.orange;
      case "Completed":
        return Colors.blue;
      default:
        return Colors.grey;
    }
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

            /// ✅ FULL WIDTH FIX IS HERE 👇
            child: SizedBox(
              width: double.infinity, // ⭐ THIS MAKES IT FULL PAGE
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
                      "Admin Rotation",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Election Progress Overview",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 25),

                    /// 📊 TABLE
                    Expanded(
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 1400, // ✅ FORCE FULL-WIDTH TABLE
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(subtleGrey),
        columnSpacing: 140,
        dataRowMinHeight: 70,
        dataRowMaxHeight: 70,

        columns: const [
          DataColumn(
            label: Text(
              "Community",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Status",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Progress",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
          ),
        ],

        rows: rotationData.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item["community"])),
              DataCell(_statusBadge(item["status"])),
              DataCell(
                SizedBox(
                  width: 400, // keeps progress aligned nicely
                  child: LinearProgressIndicator(
                    value: item["progress"] / 100,
                    minHeight: 10,
                    backgroundColor: subtleGrey,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      statusColor(item["status"]),
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    final Color bg = status == "Active"
        ? accent.withValues(alpha: 0.2)
        : status == "Pending"
            ? Colors.orange.withValues(alpha: 0.2)
            : Colors.blue.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: statusColor(status),
        ),
      ),
    );
  }
}