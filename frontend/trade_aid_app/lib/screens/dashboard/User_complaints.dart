import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/widgets/app_bar.dart';
import '/models/view_complaints.dart';
import '../../services/notification_service.dart';

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

    final complaintsRes = await supabase.from('complaints').select();

    List<ComplaintModel> list = [];

    for (var e in complaintsRes) {
      final accused = await supabase
          .from('profiles')
          .select()
          .eq('user_id', e['accused_user_id'])
          .maybeSingle();

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
          complainantName: complainant?['full_name'],
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
    if (mounted) {
      setState(() {
        _allComplaints = data;
        _loading = false;
      });
    }
  }

  /// ================= ACTIONS =================
  void _resolveComplaint(ComplaintModel complaint) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Validate Complaint",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Is this complaint valid?\n\nValid → Count increases\nInvalid → Ignored",
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 2, color: Colors.teal),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => appGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: const Text(
                    "Invalid",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
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

    _showSnackBar("Complaint reviewed", Colors.green);

    await Supabase.instance.client
        .from('complaints')
        .update({'status': 'resolved', 'is_valid': result}).eq('id', complaint.id);

    await _loadComplaints();
    await NotificationService.createNotification(
      userId: complaint.complainantId,
      title: "Complaint Resolved",
      message: "Your complaint has been reviewed.",
      type: "resolved",
    );

    await NotificationService.createNotification(
      userId: complaint.accusedUserId,
      title: "Complaint Update",
      message: "A complaint involving you has been reviewed.",
      type: "update",
    );
  }

  void _notifyAccused(ComplaintModel complaint) async {
    await NotificationService.createNotification(
      userId: complaint.accusedUserId,
      title: "Warning",
      message: "Complaints have been filed against you.",
      type: "warning",
    );
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

/// PREMIUM: Detailed View Popup
  void _showComplaintDetails(ComplaintModel complaint, int count) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(complaint.subject,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: complaint.status == 'pending' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            complaint.status.toUpperCase(),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: complaint.status == 'pending' ? Colors.orange : Colors.green),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Reported by: ${complaint.complainantName ?? complaint.reporterName}",
                        style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),

                    // Accused Profile Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          _avatar(complaint.accusedImage, complaint.accusedName),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Accused User", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(complaint.accusedName ?? "Unknown User",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(complaint.accusedAddress ?? "No address listed",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle),
                            child: Text("$count",
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text("Case Description",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(complaint.description,
                          style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
                    ),

                    if (complaint.imageUrl != null) ...[
                      const SizedBox(height: 25),
                      const Text("Evidence / Attachments",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          complaint.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // FIXED BOTTOM ACTION BAR (Moved from bottomSheet to here)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: surface,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: complaint.status == 'pending'
                  ? Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _resolveComplaint(complaint);
                            },
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: appGradient,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text("Validate & Resolve",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "RESOLVED AS ${complaint.isValid == true ? 'VALID' : 'INVALID'}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    ),
            ),
          ],
        ),
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

  Widget _buildComplaintList(List<ComplaintModel> list, {bool isResolved = false}) {
    if (list.isEmpty) {
      return const Center(child: Text("No complaints found"));
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

        return GestureDetector(
          onTap: () => _showComplaintDetails(complaint, count), 
          child: _ComplaintCard(
            complaint: complaint,
            count: count,
            isResolved: isResolved,
            onResolve: () => _resolveComplaint(complaint),
            onNotify: () => _notifyAccused(complaint),
            onRemove: () => _removeUser(complaint),
            onChat: () => _showSnackBar("Opening chat...", Colors.teal),
          ),
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
      return const Center(child: Text("No valid complaints record"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final list = users[index];
        final user = list.first;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _avatar(user.accusedImage, user.accusedName),
            title: Text(user.accusedName ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.accusedAddress ?? "No address"),
            trailing: CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.1),
              child: Text(
                "${list.length}",
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _avatar(String? image, String? name) {
    if (image != null && image.isNotEmpty) {
      return CircleAvatar(radius: 25, backgroundImage: NetworkImage(image));
    }
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.teal.shade100,
      child: Text(
        name != null && name.isNotEmpty ? name[0].toUpperCase() : "?",
        style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.bold),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  complaint.subject,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "By ${complaint.complainantName ?? complaint.reporterName}",
            style: TextStyle(color: Colors.teal.shade600, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(
            complaint.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
          if (complaint.isValid != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(complaint.isValid! ? Icons.verified : Icons.error_outline, 
                     size: 16, color: complaint.isValid! ? Colors.green : Colors.red),
                const SizedBox(width: 4),
                Text(
                  complaint.isValid! ? "Valid Complaint" : "Invalid Complaint",
                  style: TextStyle(
                    color: complaint.isValid! ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text("$count", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  const Text("Strikes", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              if (!isResolved) ...[
                Row(
                  children: [
                    _iconBtn(Icons.notifications_active_outlined, Colors.orange, onNotify),
                    if (count >= 3) _iconBtn(Icons.person_remove_outlined, Colors.red, onRemove),
                    const SizedBox(width: 8),
                    _actionTextBtn("Resolve", onResolve),
                  ],
                ),
              ] else ...[
                const Text("Closed", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTextBtn(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: appGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}