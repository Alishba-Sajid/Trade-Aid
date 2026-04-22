import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EscalatedDisputeScreen extends StatefulWidget {
  final String disputeId; // ✅ ADDED

  const EscalatedDisputeScreen({super.key, required this.disputeId});

  @override
  State<EscalatedDisputeScreen> createState() => _EscalatedDisputeScreenState();
}

class _EscalatedDisputeScreenState extends State<EscalatedDisputeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final supabase = Supabase.instance.client;

  Map<String, dynamic>? data; // ✅ ADDED
  bool isLoading = true; // ✅ ADDED

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();

    fetchDispute(); // ✅ ADDED
  }

  /// ✅ FETCH DATA
  Future<void> fetchDispute() async {
    try {
      final response = await supabase
          .from('dispute_details_view')
          .select()
          .eq('dispute_id', widget.disputeId)
          .single();

      setState(() {
        data = response;
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

    /// ✅ LOADING (NO UI CHANGE)
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /// ✅ SAFE DATA
    final d = data ?? {};

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // 🌊 SAME GRADIENT
              Container(
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
              ),

              // ✨ FLOATING CIRCLES
              ...List.generate(6, (i) {
                final size = 80.0 + i * 20;
                return Positioned(
                  left: (i * 150) % MediaQuery.of(context).size.width,
                  top: 120 +
                      60 *
                          sin((_controller.value * 2 * pi) + i.toDouble()),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 192, 16, 16)
                          .withValues(alpha: 0.08),
                    ),
                  ),
                );
              }),

              Column(
                children: [
                  // 🔹 HEADER (UNCHANGED)
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 55, 128, 124).withValues(alpha: 0.95),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Trade&Aid",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.search), onPressed: () {}),
                            IconButton(
                                icon: const Icon(Icons.notifications_none),
                                onPressed: () {}),
                            const SizedBox(width: 10),
                            const CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  AssetImage('assets/profile.png'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 🧊 CONTENT
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 14,
                                offset: Offset(0, 8)),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Escalated Dispute Resolution",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Review and resolve disputes that community admins were unable to handle.",
                              ),

                              const SizedBox(height: 30),
                              _sectionTitle("Dispute Details"),

                              /// ✅ MAPPED DATA (ONLY CHANGE HERE)
                              _detailRow("Dispute ID",
                                  "#${d['dispute_id']?.toString().substring(0, 6) ?? ''}"),
                              _detailRow("Date Reported",
                                  d['date_reported']?.toString().substring(0, 10) ?? ''),
                              _detailRow("Community",
                                  d['community_name'] ?? 'N/A'),
                              _detailRow("Subject",
                                  d['subject'] ?? 'No Subject'),
                              _detailRow("Description",
                                  d['description'] ?? 'No Description'),
                              _detailRow("Status",
                                  d['status'] ?? 'Unknown'),
                              _detailRow(
                                "Parties Involved",
                                "${d['complainant_name'] ?? 'User'} vs ${d['accused_name'] ?? 'User'}",
                              ),

                              const SizedBox(height: 30),
                              _sectionTitle("Community Admin Actions"),
                              _detailRow("Admin Decision", "Pending"),
                              _detailRow("Actions Taken", "None"),
                              _detailRow("Evidence",
                                  d['attachment_url'] ?? "No attachment"),

                              const SizedBox(height: 30),
                              _sectionTitle("Communication"),

                              _messageBubble(
                                sender: "Community Admin",
                                message:
                                    "We’ve reviewed the evidence and believe User A violated guidelines.",
                                isLeft: true,
                              ),

                              Padding(
                                padding: const EdgeInsets.only(right: 40),
                                child: _messageBubble(
                                  sender: "Admin",
                                  message:
                                      "Thank you. We’ll review and respond shortly.",
                                  isLeft: false,
                                ),
                              ),

                              const SizedBox(height: 25),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Type your message...",
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.teal.shade600,
                                        foregroundColor: Colors.black,
                                      ),
                                      onPressed: () {},
                                      child: const Text("Send"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🔹 HELPERS (UNCHANGED)
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _messageBubble({
    required String sender,
    required String message,
    required bool isLeft,
  }) {
    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              isLeft ? Colors.grey.shade200 : Colors.teal.shade600,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
              isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(sender,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLeft ? Colors.black87 : Colors.white)),
            const SizedBox(height: 4),
            Text(message,
                style: TextStyle(
                    color: isLeft ? Colors.black87 : Colors.white)),
          ],
        ),
      ),
    );
  }
}