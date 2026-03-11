import 'dart:math';
import 'package:flutter/material.dart';
import 'dispute_details.dart';

class EscalatedCases extends StatefulWidget {
  const EscalatedCases({super.key});

  @override
  State<EscalatedCases> createState() => _EscalatedCasesState();
}

class _EscalatedCasesState extends State<EscalatedCases>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, String>> caseData = const [
    {
      "id": "#12345",
      "participants": "Alice Johnson vs Bob Williams",
      "status": "Open",
      "date": "2024-07-26"
    },
    {
      "id": "#12346",
      "participants": "Charlie Davis vs Eve Green",
      "status": "In Review",
      "date": "2024-07-25"
    },
    {
      "id": "#12347",
      "participants": "Grace Miller vs Henry Clark",
      "status": "Pending",
      "date": "2024-07-24"
    },
    {
      "id": "#12348",
      "participants": "Ivy White vs Jack Brown",
      "status": "Open",
      "date": "2024-07-23"
    },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              /// 🌊 SAME ANIMATED GRADIENT
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal.shade600,
                      Colors.teal.shade300,
                      Colors.cyan.shade200,
                    ],
                    stops: [
                      0.2,
                      0.6 + 0.2 * sin(_controller.value * pi * 2),
                      1.0,
                    ],
                  ),
                ),
              ),

              /// ✨ FLOATING CIRCLES
              ...List.generate(6, (i) {
                final size = 80.0 + i * 20;
                return Positioned(
                  left: (i * 140) % MediaQuery.of(context).size.width,
                  top: 120 +
                      60 *
                          sin((_controller.value * 2 * pi) + i.toDouble()),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                );
              }),

              /// 📦 MAIN GLASS CARD
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Escalated Cases",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Manage and resolve escalated disputes",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),

                      /// 🔍 SEARCH BAR (same style)
                      Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      "Search by Case ID or Participant",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 📊 DATA TABLE (SAME AS PRODUCT RESOURCE)
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(minWidth: 1400),
                            child: DataTable(
                              columnSpacing: 70,
                              headingRowColor:
                                  WidgetStateColor.resolveWith(
                                      (_) => Colors.grey.shade100),
                              columns: const [
                                DataColumn(
                                    label: Text(
                                  "Case ID",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                )),
                                DataColumn(
                                    label: Text(
                                  "Participants",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                )),
                                DataColumn(
                                    label: Text(
                                  "Status",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                )),
                                DataColumn(
                                    label: Text(
                                  "Date",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                )),
                                DataColumn(
                                    label: Text(
                                  "Actions",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                )),
                              ],
                              rows: caseData.map((c) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(c["id"]!)),
                                    DataCell(Text(c["participants"]!)),
                                    DataCell(_statusBadge(c["status"]!)),
                                    DataCell(Text(c["date"]!)),
                                    DataCell(
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const EscalatedDisputeScreen(),
  ),
);
                                        },
                                        child: const Text(
                                          "View",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
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
            ],
          );
        },
      ),
    );
  }

  /// 🟡 STATUS BADGE (same concept)
  Widget _statusBadge(String status) {
    final Color bg = status == "Open"
        ? Colors.green.shade100
        : status == "In Review"
            ? Colors.orange.shade100
            : Colors.red.shade100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}