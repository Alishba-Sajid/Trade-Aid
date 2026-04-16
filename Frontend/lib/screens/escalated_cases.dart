import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dispute_details.dart';

class EscalatedCases extends StatefulWidget {
  const EscalatedCases({super.key});

  @override
  State<EscalatedCases> createState() => _EscalatedCasesState();
}

class _EscalatedCasesState extends State<EscalatedCases>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// ✅ Supabase
  final supabase = Supabase.instance.client;

  /// ✅ Dynamic data
  List<Map<String, dynamic>> caseData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();

    fetchCases(); // ✅ fetch from Supabase
  }

  /// ✅ FETCH FROM VIEW
  Future<void> fetchCases() async {
    try {
      final response = await supabase
          .from('escalated_cases_view')
          .select();

      setState(() {
        caseData = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => isLoading = false);
    }
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

                      /// 🔍 SEARCH BAR (UNCHANGED)
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

                      /// 📊 DATA TABLE
                      Expanded(
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator())
                            : SingleChildScrollView(
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        "Accuser name",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        "Status",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        "Date",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        "Actions",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ],
                                    rows: caseData.map((c) {
                                      return DataRow(
                                        cells: [
                                          /// Case ID
                                          DataCell(Text(
                                            c['id'] != null
                                                ? "#${c['id'].toString().substring(0, 6)}"
                                                : '',
                                          )),

                                          /// Accuser Name
                                          DataCell(Text(
                                              c['accuser_name'] ??
                                                  'Unknown')),

                                          /// Status
                                          DataCell(_statusBadge(
                                              c['status'] ?? '')),

                                          /// Date
                                          DataCell(Text(
                                            c['created_at'] != null
                                                ? c['created_at']
                                                    .toString()
                                                    .substring(0, 10)
                                                : '',
                                          )),

                                          /// Action
                                          DataCell(
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const EscalatedDisputeScreen(),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                "View",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
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

  /// 🟡 STATUS BADGE (UNCHANGED)
  Widget _statusBadge(String status) {
    final s = status.toLowerCase();

    final Color bg = s == "open"
        ? Colors.green.shade100
        : s == "in review"
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