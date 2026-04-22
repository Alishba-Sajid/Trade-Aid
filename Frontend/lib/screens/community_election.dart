import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final supabase = Supabase.instance.client;

  List<Map<String, String>> electionHistoryData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();

    fetchElectionHistory();
  }

  Future<void> fetchElectionHistory() async {
    try {
      final response =
          await supabase.from('election_nominations_view').select();

      final List<Map<String, String>> temp = [];

      for (var row in response) {
        // ✅ FIX DATE
        final rawDate = row['election_date'];
        String formattedDate = '';

        if (rawDate != null) {
          final dateTime = DateTime.parse(rawDate).toLocal();
          formattedDate =
              "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
        }

        temp.add({
          "date": formattedDate,
          "nomination": row['nomination'] ?? "No nomination", // ✅ FIXED
          "community_name": row['community_name'] ?? '',
          "before": row['before']?.toString() ?? '',
          "votes": row['total_votes']?.toString() ?? '0', // ✅ NEW
          "After": row['after']?.toString() ?? '',
        });
      }

      setState(() {
        electionHistoryData = temp;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching elections: $e");
      setState(() {
        isLoading = false;
      });
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
          return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
  gradient: LinearGradient(
    colors: [
 const Color.fromARGB(255, 41, 207, 191),
                    const Color.fromARGB(255, 46, 148, 153),    
                    ],
    stops: [
      0.3,
      0.7 + 0.2 * sin(_controller.value * pi * 2),
    ],
  ),
),

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

                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minWidth: 1400),
                                child: DataTable(
                                  headingRowColor:
                                      WidgetStateProperty.all(subtleGrey),
                                  columnSpacing: 140,
                                  dataRowMinHeight: 70,
                                  dataRowMaxHeight: 70,

                                  columns: const [
                                    DataColumn(label: Text("Election Date",style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text("Nomination",style: TextStyle(
                                              fontWeight: FontWeight.bold))), // ✅
                                    DataColumn(label: Text("Community Name",style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text("Before",style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text("Votes",style: TextStyle(
                                              fontWeight: FontWeight.bold))), // ✅ NEW
                                    DataColumn(label: Text("After",style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  ],

                                  rows: electionHistoryData.map((item) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(item["date"] ?? "")),
                                        DataCell(
                                            Text(item["nomination"] ?? "")), // ✅
                                        DataCell(Text(
                                          item["community_name"] ?? "",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )),
                                        DataCell(Text(
                                          item["before"] ?? "",
                                          style: const TextStyle(
                                            color: accent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                        DataCell(Text(
                                          item["votes"] ?? "0", // ✅
                                          style: const TextStyle(
                                            color: accent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                        DataCell(Text(
                                          item["After"] ?? "",
                                          style: const TextStyle(
                                            color: accent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
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