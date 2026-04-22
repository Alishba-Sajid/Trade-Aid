import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  String selectedTab = 'All';

  late RealtimeChannel requestChannel;
  late RealtimeChannel complaintChannel;

  // ✅ FETCH DATA (NO FILTER BUG)
  Future<void> fetchAllNotifications() async {
  final requests =
      await supabase.from('community_join_requests').select();

  final complaints =
      await supabase.from('complaints').select();

  // ✅ FORMAT MEMBER REQUESTS
  final formattedRequests = (requests as List)
      .where((item) => item['status'] == 'pending')
      .map((item) {
    return {
      'title': item['requester_id'] != null
          ? 'New member request from ${item['requester_id']}'
          : 'New member request',
      'type': 'Member Requests', // ✅ IMPORTANT
      'created_at': item['created_at'] ?? '',
    };
  }).toList();

  // ✅ FORMAT DISPUTES
  final formattedComplaints = (complaints as List)
      .where((item) => item['status'] == 'pending')
      .map((item) {
    return {
      'title': item['subject'] != null
          ? 'Dispute: ${item['subject']}'
          : 'Dispute reported',
      'type': 'Disputes', // ✅ IMPORTANT
      'created_at': item['created_at'] ?? '',
    };
  }).toList();

  // ✅ MERGE BOTH
  final all = [...formattedRequests, ...formattedComplaints];

  // ✅ SAFE SORT
  all.sort((a, b) {
    final aTime = DateTime.tryParse(a['created_at'] ?? '');
    final bTime = DateTime.tryParse(b['created_at'] ?? '');

    return (bTime ?? DateTime.now())
        .compareTo(aTime ?? DateTime.now());
  });

  setState(() {
    notifications = all;
    isLoading = false;
  });
}

  // ✅ REALTIME REQUESTS
  void setupRequestRealtime() {
    requestChannel = supabase
        .channel('request-channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'community_join_requests',
          callback: (payload) {
            final data = payload.newRecord;

            if (data['status'] == 'pending') {
              setState(() {
                notifications.insert(0, {
                  'title':
                      'New member request from ${data['requester_id']}',
                  'type': 'Member Requests',
                  'created_at': data['created_at'],
                });
              });
            }
          },
        )
        .subscribe();
  }

  // ✅ REALTIME COMPLAINTS
  void setupComplaintRealtime() {
    complaintChannel = supabase
        .channel('complaint-channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'complaints',
          callback: (payload) {
            final data = payload.newRecord;

            if (data['status'] == 'pending') {
              setState(() {
                notifications.insert(0, {
                  'title': 'Dispute: ${data['subject']}',
                  'type': 'Disputes',
                  'created_at': data['created_at'],
                });
              });
            }
          },
        )
        .subscribe();
  }

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();

    fetchAllNotifications();
    setupRequestRealtime();
    setupComplaintRealtime();
  }

  @override
  void dispose() {
    _controller.dispose();
    supabase.removeChannel(requestChannel);
    supabase.removeChannel(complaintChannel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedTab == 'All'
        ? notifications
        : notifications.where((n) => n['type'] == selectedTab).toList();

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // BACKGROUND
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

              // MAIN CARD
              Padding(
                padding: const EdgeInsets.all(30),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Notifications Inbox",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // TABS
                      Row(
                        children: [
                          for (final tab in [
                            'All',
                            'Member Requests',
                            'Disputes'
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => selectedTab = tab),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selectedTab == tab
                                        ? Colors.teal
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    tab,
                                    style: TextStyle(
                                      color: selectedTab == tab
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // LIST
                      Expanded(
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator())
                            : filtered.isEmpty
                                ? const Center(
                                    child: Text("No notifications found"))
                                : ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final item = filtered[index];

                                      IconData icon =
                                          Icons.notifications;

                                      if (item['type'] ==
                                          'Member Requests') {
                                        icon = Icons.person_add;
                                      } else if (item['type'] ==
                                          'Disputes') {
                                        icon = Icons.report;
                                      }

                                      return ListTile(
  leading: Icon(icon),

  title: Text(
    item['title']?.toString() ?? 'No Title',
  ),

  subtitle: Text(
    item['created_at'] != null
        ? item['created_at'].toString()
        : 'No Date',
  ),
);
                                    },
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
}