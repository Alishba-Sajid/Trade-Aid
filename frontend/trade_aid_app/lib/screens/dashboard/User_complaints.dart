import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/widgets/app_bar.dart';
import '/models/view_complaints.dart';

// Assuming these are defined in your theme constants
const Color backgroundLight = Color(0xFFF5F5F5);
const Color surface = Colors.white;
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

/// ================= REPOSITORY =================
class ComplaintRepository {
  Future<List<ComplaintModel>> fetchComplaints() async {
    final supabase = Supabase.instance.client;

  final complaintsRes = await supabase
    .from('complaints')
    .select();

    List<ComplaintModel> list = [];

    for (var e in complaintsRes) {
      // accused profile
      final accused = await supabase
          .from('profiles')
          .select()
          .eq('user_id', e['accused_user_id'])
          .maybeSingle();

      // complainant profile
      final complainant = await supabase
          .from('profiles')
          .select()
          .eq('user_id', e['complainant_id'])
          .maybeSingle();

      list.add(
        ComplaintModel(
          id: e['id'],
          subject: e['subject'],
          reporterName: complainant?['full_name'] ?? "Unknown",
          complainantName: complainant?['full_name'], // ✅ ADD THIS
          description: e['description'],
          imageUrl: e['attachment_url'],
          complainantId: e['complainant_id'],
          accusedUserId: e['accused_user_id'],
          communityId: e['community_id'],
          status: e['status'] ?? 'pending',
          isValid: e['is_valid'],
          accusedName: accused?['full_name'],
          accusedImage: accused?['profile_image_url'],
          accusedAddress: accused?['address'],
        ),
      );
    }

    return list;
  }
}

/// ================= SCREEN =================
class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final ComplaintRepository _repository = ComplaintRepository();

  List<ComplaintModel> _allComplaints = [];
  bool _loading = true;
  int _tabIndex = 0;

  List<ComplaintModel> get _pending =>
      _allComplaints.where((c) => c.status == 'pending').toList();

  List<ComplaintModel> get _resolved =>
      _allComplaints.where((c) => c.status == 'resolved').toList();

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final data = await _repository.fetchComplaints();

    setState(() {
      _allComplaints = data;
      _loading = false;
    });
  }

  /// ================= ACTIONS =================
  void _resolveComplaint(ComplaintModel complaint) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Validate Complaint", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              "Is this complaint valid?\n\nValid → Count increases\nInvalid → Ignored"),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            // INVALID BUTTON: White background, Gradient border, Gradient text
            InkWell(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 2, color: Colors.teal), // Fallback for border color
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => appGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: const Text(
                    "Invalid",
                    style: TextStyle(
                      color: Colors.white, // Required for ShaderMask
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // VALID BUTTON: Gradient background, White text
            InkWell(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: appGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Valid",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == null) return;

  final response = await Supabase.instance.client
    .from('complaints')
    .update({
      'status': 'resolved',
      'is_valid': result,
    })
    .eq('id', complaint.id)
    .select();

print("Update response: $response");

    _showSnackBar("Complaint reviewed", Colors.green);

    await _loadComplaints(); 
  }

  void _notifyAccused(ComplaintModel complaint) async {
    await Supabase.instance.client.from('notifications').insert({
      "community_id": complaint.communityId,
      "title": "Warning",
      "message": "Complaints have been filed against you.",
      "type": "warning",
    });

    _showSnackBar("User notified", Colors.orange);
  }

  void _removeUser(ComplaintModel complaint) async {
    await Supabase.instance.client
        .from('community_members')
        .delete()
        .eq('user_id', complaint.accusedUserId)
        .eq('community_id', complaint.communityId);

    _showSnackBar("User removed from community", Colors.red);
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBarWidget(
        title: "Users Complaints",
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          /// TABS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tabBtn("Complaints", 0),
              _tabBtn("Counts", 1),
              _tabBtn("Resolved", 2),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String title, int index) {
    final selected = _tabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? Colors.teal : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.teal : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_tabIndex == 0) {
      return _buildComplaintList(_pending);
    } else if (_tabIndex == 1) {
      return _buildCountsTab();
    } else {
      return _buildComplaintList(_resolved, isResolved: true);
    }
  }

  Widget _buildComplaintList(List<ComplaintModel> list,
      {bool isResolved = false}) {
    if (list.isEmpty) {
      return const Center(child: Text("No complaints"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final complaint = list[index];

        final count = _allComplaints
            .where((c) =>
                c.accusedUserId == complaint.accusedUserId &&
                c.status == 'resolved' &&
                c.isValid == true)
            .length;

        return _ComplaintCard(
          complaint: complaint,
          count: count,
          isResolved: isResolved,
          onResolve: () => _resolveComplaint(complaint),
          onNotify: () => _notifyAccused(complaint),
          onRemove: () => _removeUser(complaint),
          onChat: () => _showSnackBar("Opening chat...", Colors.teal),
        );
      },
    );
  }

  Widget _buildCountsTab() {
    final validResolved = _allComplaints
        .where((c) => c.status == 'resolved' && c.isValid == true)
        .toList();

    final Map<String, List<ComplaintModel>> grouped = {};

    for (var c in validResolved) {
      grouped.putIfAbsent(c.accusedUserId, () => []).add(c);
    }

    final users = grouped.values.toList();

    if (users.isEmpty) {
      return const Center(child: Text("No valid complaints"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final list = users[index];
        final user = list.first;

        return ListTile(
          leading: _avatar(user.accusedImage, user.accusedName),
          title: Text(user.accusedName ?? "Unknown"),
          subtitle: Text(user.accusedAddress ?? "No address"),
          trailing: CircleAvatar(
            backgroundColor: Colors.red.withOpacity(0.1),
            child: Text("${list.length}",
                style: const TextStyle(color: Colors.red)),
          ),
        );
      },
    );
  }

  Widget _avatar(String? image, String? name) {
    if (image != null && image.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(image),
      );
    }

    return CircleAvatar(
      backgroundColor: Colors.teal,
      child: Text(
        name != null && name.isNotEmpty ? name[0].toUpperCase() : "?",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

/// ================= CARD =================
class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final int count;
  final bool isResolved;
  final VoidCallback onResolve;
  final VoidCallback onNotify;
  final VoidCallback onRemove;
  final VoidCallback onChat;

  const _ComplaintCard({
    required this.complaint,
    required this.count,
    required this.onResolve,
    required this.onNotify,
    required this.onRemove,
    required this.onChat,
    this.isResolved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(complaint.subject,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text("By ${complaint.complainantName ?? complaint.reporterName}"),
          const SizedBox(height: 12),
          Text(complaint.description),
          if (complaint.isValid != null) ...[
            const SizedBox(height: 6),
            Text(
              complaint.isValid! ? "✔ Valid Complaint" : "✖ Invalid Complaint",
              style: TextStyle(
                color: complaint.isValid! ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (complaint.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                complaint.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.red.withOpacity(0.1),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              const Text("Complaints against this user"),
            ],
          ),
          const SizedBox(height: 16),
          if (!isResolved) ...[
            Row(
              children: [
                Expanded(child: _btn("Resolve", Icons.check, onResolve)),
                const SizedBox(width: 8),
                _iconBtn(Icons.notifications, Colors.orange, onNotify),
                if (count >= 3) _iconBtn(Icons.delete, Colors.red, onRemove),
              ],
            )
          ] else ...[
            const Text("Resolved",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
          ]
        ],
      ),
    );
  }

  Widget _btn(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.teal),
            const SizedBox(width: 6),
            Text(text,
                style: const TextStyle(
                    color: Colors.teal, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}