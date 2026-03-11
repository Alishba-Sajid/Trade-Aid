import 'dart:math';
import 'package:flutter/material.dart';

const Color dark = Color(0xFF0B2F2A);
const Color surface = Color(0xFFFFFFFF);
const Color subtleGrey = Color(0xFFF2F2F2);
const Color accent = Color(0xFF119E90);

class CommunityElectionHistoryScreen extends StatefulWidget {
  const CommunityElectionHistoryScreen({super.key});

  @override
  State<CommunityElectionHistoryScreen> createState() =>
      _CommunityElectionHistoryScreenState();
}

class _CommunityElectionHistoryScreenState
    extends State<CommunityElectionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, String>> electionHistoryData = const [
    {
      "date": "2023-04-15",
      "candidates": "Alice Johnson, Robert Smith",
      "results": "Alice Johnson (Winner)",
      "turnout": "65%",
    },
    {
      "date": "2022-11-20",
      "candidates": "Emily Davis, Michael Brown",
      "results": "Emily Davis (Winner)",
      "turnout": "72%",
    },
    {
      "date": "2022-05-10",
      "candidates": "Sarah Clark, David Wilson",
      "results": "Sarah Clark (Winner)",
      "turnout": "58%",
    },
    {
      "date": "2021-12-05",
      "candidates": "Jessica Lee, Christopher Taylor",
      "results": "Jessica Lee (Winner)",
      "turnout": "69%",
    },
    {
      "date": "2021-06-20",
      "candidates": "Olivia Martinez, Daniel Anderson",
      "results": "Olivia Martinez (Winner)",
      "turnout": "62%",
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

            /// ✅ FULL-WIDTH CARD (SAME AS ADMIN ROTATION)
            child: SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 TITLE
                    const Text(
                      "Community Election History",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "View the complete historical record of past elections",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 25),

                    /// 📊 TABLE
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 1400, // ⭐ SAME WIDTH CONTROL
                          ),
                          child: DataTable(
                            headingRowColor:
                                WidgetStateProperty.all(subtleGrey),
                            columnSpacing: 140,
                            dataRowMinHeight: 70,
                            dataRowMaxHeight: 70,

                            columns: const [
                              DataColumn(
                                label: Text(
                                  "Election Date",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: dark,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Candidates",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: dark,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Results",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: dark,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Voter Turnout",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: dark,
                                  ),
                                ),
                              ),
                            ],

                            rows: electionHistoryData.map((item) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(item["date"]!)),
                                  DataCell(Text(item["candidates"]!)),
                                  DataCell(Text(
                                    item["results"]!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  )),
                                  DataCell(
                                    Text(
                                      item["turnout"]!,
                                      style: const TextStyle(
                                        color: accent,
                                        fontWeight: FontWeight.bold,
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
}