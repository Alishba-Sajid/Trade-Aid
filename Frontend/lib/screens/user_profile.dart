import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

/// 🌿 Premium Industrial Palette
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
const Color subtleGrey = Color(0xFFF2F2F2);

class UserProfile extends StatefulWidget {
  final String userId;
  const UserProfile({super.key, required this.userId});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> activityLogs = [];
  List<Map<String, dynamic>> fraudLogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
  setState(() => isLoading = true);

  try {
    // Fetch profile
    final profileResponse = await supabase
        .from('user_profile_view')
        .select()
        .eq('user_id', widget.userId)
        .maybeSingle();

    if (profileResponse == null) {
      setState(() {
        profile = null;
        activityLogs = [];
        fraudLogs = [];
        isLoading = false;
      });
      return;
    }

    profile = Map<String, dynamic>.from(profileResponse);

    // Fetch activity logs
    // 🔽🔽🔽 ONLY THIS PART UPDATED 🔽🔽🔽

// Fetch activity logs (SAFE + CORRECT)
final activityResponse = await supabase
    .from('user_activity_logs')
    .select()
    .eq('user_id', widget.userId)
    .order('date', ascending: false);

// ✅ FIXED HERE
List<Map<String, dynamic>> logs =
    (activityResponse as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

activityLogs = logs.map((log) {
  return {
    'date': log['date']?.toString() ?? '',
    'profile status': log['profile_status'] ?? '',
    'transaction status': log['transaction_status'] ?? '',
    'product posted': log['product_posted'] ?? '',
    'resource posted': log['resource_posted'] ?? '',
  };
}).toList();

// 🔼🔼🔼 ONLY THIS PART UPDATED 🔼🔼🔼
    // Dummy fraud logs
    fraudLogs = [
      {
        "date": "2024-08-01",
        "issue": "Multiple failed logins",
        "severity": "Medium",
        "status": "Resolved"
      },
      {
        "date": "2024-07-15",
        "issue": "Suspicious transaction",
        "severity": "High",
        "status": "Flagged"
      }
    ];

    setState(() => isLoading = false);
  } catch (e, st) {
    developer.log('ERROR fetching user: $e', name: 'UserProfile', error: e, stackTrace: st);
    setState(() => isLoading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text("User not found")),
      );
    }

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: accent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 PROFILE CARD
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        profile!['profile_image_url'] != null &&
                                profile!['profile_image_url'] != ''
                            ? NetworkImage(profile!['profile_image_url'])
                            : const AssetImage('assets/default.png')
                                as ImageProvider,
                  ),
                  const SizedBox(width: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile!['full_name'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: darkPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("User ID: ${profile!['user_id']}"),
                      Text("Joined: ${profile!['created_at'] ?? '—'}"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 🔹 USER INFORMATION
            sectionTitle("User Information"),
            const SizedBox(height: 12),
            buildTable(
              ["Role", "Community", "Phone", "Address"],
              [
                [
                  profile!['role']?.toString() ?? '—',
                  profile!['community_name']?.toString() ?? '—',
                  profile!['phone']?.toString() ?? '—',
                  profile!['address']?.toString() ?? '—',
                ]
              ],
            ),

            const SizedBox(height: 32),

            // 🔹 ACTIVITY LOG
            sectionTitle("Activity Log"),
            const SizedBox(height: 12),
            buildTable(
              ["Date", "Profile Status",  "Transaction status", "Product posted","Resource posted"],
              activityLogs.map((log) {
                return [
                  log['date']?.toString() ?? '',
                  log['profile status']?.toString() ?? '',
                  log['transaction status']?.toString() ?? '',
                  log['product posted']?.toString() ?? '',
                  log['resource posted']?.toString() ?? '',
                ];
              }).toList(),
            ),

            const SizedBox(height: 32),

            // 🔹 DUMMY FRAUD LOG
            sectionTitle("Fraud History"),
            const SizedBox(height: 12),
            buildTable(
              ["Date", "Issue", "Severity", "Status"],
              fraudLogs.map((f) {
                return [
                  f['date']?.toString() ?? '',
                  f['issue']?.toString() ?? '',
                  f['severity']?.toString() ?? '',
                  f['status']?.toString() ?? '',
                ];
              }).toList(),
            ),

            const SizedBox(height: 32),

            // 🔹 ADMIN ACTIONS
            sectionTitle("Admin Actions"),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  ),
                  onPressed: () {
                    // Add your suspend logic here
                  },
                  child: const Text(
                    "Suspend User",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    side: const BorderSide(color: darkPrimary),
                  ),
                  onPressed: () {
                    // Add your ban logic here
                  },
                  child: const Text(
                    "Ban User",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 🔹 SECTION TITLE
  static Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: dark,
      ),
    );
  }

  // 🔹 TABLE WIDGET
  Widget buildTable(List<String> headers, List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: subtleGrey),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: subtleGrey),
            children: headers
                .map(
                  (h) => Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      h,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          ...rows.map(
            (row) => TableRow(
              children: row
                  .map(
                    (cell) => Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(cell),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}