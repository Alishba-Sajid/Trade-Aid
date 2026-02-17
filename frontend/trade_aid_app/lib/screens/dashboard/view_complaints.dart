import 'package:flutter/material.dart';
import '/widgets/app_bar.dart';
import '/models/view_complaints.dart';

/// ================= REPOSITORY (BACKEND READY) =================
/// Later replace Future.delayed with PostgreSQL API calls
class ComplaintRepository {
  Future<List<ComplaintModel>> fetchComplaints() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      ComplaintModel(
        id: "101",
        subject: "Defective Product Received",
        reporterName: "Ali Khan",
        category: "Products",
        description:
            "The stitching was damaged. I have attached the photo for reference.",
        imageUrl:
            "https://images.unsplash.com/photo-1581578731548-c64695cc6952",
      ),
      ComplaintModel(
        id: "102",
        subject: "Access Denied to Library",
        reporterName: "Sara Ahmed",
        category: "Resources",
        description:
            "My booking was confirmed but the smart lock did not accept credentials.",
      ),
    ];
  }

  Future<void> resolveComplaint(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> suspendUser(String id, int days) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

/// ================= SCREEN =================
class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() =>
      _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final ComplaintRepository _repository = ComplaintRepository();

  List<ComplaintModel> _allComplaints = [];
  bool _loading = true;

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

  void _resolveComplaint(int index) async {
    final id = _allComplaints[index].id;

    await _repository.resolveComplaint(id);

    setState(() {
      _allComplaints.removeAt(index);
    });

    _showSnackBar(
        "Complaint resolved and archived.", Colors.green);
  }

  void _showSuspensionDialog(int index) {
    int selectedDays = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding:
            const EdgeInsets.fromLTRB(20, 22, 20, 10),
        titlePadding:
            const EdgeInsets.fromLTRB(20, 20, 20, 0),
        title: const Row(
          children: [
            Icon(Icons.timer, color: darkPrimary),
            SizedBox(width: 10),
            Text(
              "Set Suspension",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkPrimary),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "User access will be restricted. After this period, the ticket will auto-resolve.",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      height: 1.4),
                ),
                const SizedBox(height: 22),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "$selectedDays Day(s)",
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color:
                              Color.fromARGB(255, 164, 10, 10),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Suspension Duration",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Slider(
                  activeColor:
                      const Color.fromARGB(255, 164, 10, 10),
                  inactiveColor:
                      Colors.redAccent.withOpacity(0.2),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  value: selectedDays.toDouble(),
                  onChanged: (v) =>
                      setDialogState(
                          () => selectedDays = v.toInt()),
                ),
              ],
            );
          },
        ),
        actionsPadding:
            const EdgeInsets.fromLTRB(15, 8, 15, 15),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                        color: accentTeal, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                  ),
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(
                          color: accentTeal,
                          fontWeight:
                              FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        const Color.fromARGB(
                            255, 164, 10, 10),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                  ),
                  onPressed: () async {
                    final id =
                        _allComplaints[index].id;

                    await _repository.suspendUser(
                        id, selectedDays);

                    setState(() {
                      _allComplaints[index]
                              .status =
                          ComplaintStatus
                              .suspended;
                      _allComplaints[index]
                              .suspensionEndDate =
                          DateTime.now().add(
                              Duration(
                                  days:
                                      selectedDays));
                    });

                    Navigator.pop(context);

                    _showSnackBar(
                        "Suspended for $selectedDays days.",
                        Colors.redAccent);
                  },
                  child: const Text("Confirm",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating),
    );
  }

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
          _buildStatsHeader(),
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator())
                : _allComplaints.isEmpty
                    ? const Center(
                        child: Text(
                        "No active complaints",
                        style: TextStyle(
                            color: Colors.grey),
                      ))
                    : ListView.builder(
                        padding:
                            const EdgeInsets
                                .symmetric(
                                    horizontal:
                                        16),
                        itemCount:
                            _allComplaints.length,
                        itemBuilder:
                            (context, index) =>
                                _ComplaintCard(
                          complaint:
                              _allComplaints[
                                  index],
                          onResolve: () =>
                              _resolveComplaint(
                                  index),
                          onSuspend: () =>
                              _showSuspensionDialog(
                                  index),
                          onChat: () =>
                              _showSnackBar(
                                  "Opening Chat with User...",
                                  accentTeal),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _chip(
              "Open: ${_allComplaints.length}",
              accentTeal),
          const SizedBox(width: 8),
          _chip(
              "Suspended: ${_allComplaints.where((e) => e.status == ComplaintStatus.suspended).length}",
              const Color.fromARGB(
                  255, 164, 10, 10)),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(
              color: color,
              fontWeight:
                  FontWeight.bold,
              fontSize: 12)),
    );
  }
}

/// ================= CARD =================
class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback onResolve;
  final VoidCallback onSuspend;
  final VoidCallback onChat;

  const _ComplaintCard({
    required this.complaint,
    required this.onResolve,
    required this.onSuspend,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    bool isSuspended =
        complaint.status ==
            ComplaintStatus.suspended;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color:
                  Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          _buildHeader(isSuspended),
          Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(complaint.subject,
                    style:
                        const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                darkPrimary)),
                const SizedBox(height: 4),
                Text(
                    "Reported by ${complaint.reporterName}",
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13)),
                const Divider(height: 30),
                Text(complaint.description,
                    style: TextStyle(
                        color: dark
                            .withOpacity(0.8),
                        height: 1.5)),
                if (complaint.imageUrl !=
                    null) ...[
                  const SizedBox(
                      height: 16),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                    child: Image.network(
                        complaint.imageUrl!,
                        height: 160,
                        width:
                            double.infinity,
                        fit:
                            BoxFit.cover),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: _btn(
                            "Chat",
                            Icons
                                .chat_bubble_outline,
                            darkPrimary,
                            false,
                            onChat)),
                    const SizedBox(
                        width: 10),
                    Expanded(
                        child: _btn(
                            "Resolve",
                            Icons
                                .check_circle,
                            Colors.green,
                            true,
                            onResolve)),
                    const SizedBox(
                        width: 10),
                    _iconBtn(
                        Icons.block,
                        const Color
                            .fromARGB(255,
                            164, 10, 10),
                        onSuspend),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSuspended) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12),
      decoration: BoxDecoration(
        color: isSuspended
            ? Colors.redAccent
                .withOpacity(0.1)
            : accentTeal
                .withOpacity(0.1),
        borderRadius:
            const BorderRadius.only(
                topLeft:
                    Radius.circular(24),
                topRight:
                    Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                  isSuspended
                      ? Icons.timer
                      : Icons
                          .pending_actions,
                  size: 16,
                  color: isSuspended
                      ? const Color
                          .fromARGB(255,
                          164, 10, 10)
                      : accentTeal),
              const SizedBox(width: 8),
              Text(
                  isSuspended
                      ? "SUSPENDED"
                      : "PENDING",
                  style: TextStyle(
                      color: isSuspended
                          ? const Color
                              .fromARGB(
                                  255,
                                  164,
                                  10,
                                  10)
                          : accentTeal,
                      fontWeight:
                          FontWeight.w900,
                      fontSize: 11)),
            ],
          ),
          Text(
              complaint.category
                  .toUpperCase(),
              style:
                  const TextStyle(
                      fontSize: 10,
                      fontWeight:
                          FontWeight
                              .bold,
                      color:
                          Colors.grey)),
        ],
      ),
    );
  }

  Widget _btn(String label,
      IconData icon,
      Color color,
      bool filled,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(15),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: filled
              ? color
              : color.withOpacity(0.08),
          borderRadius:
              BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Icon(icon,
                size: 18,
                color: filled
                    ? Colors.white
                    : color),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: filled
                        ? Colors.white
                        : color,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon,
      Color color,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(15),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color:
                color.withOpacity(0.1),
            borderRadius:
                BorderRadius
                    .circular(15)),
        child: Icon(icon,
            color: color, size: 20),
      ),
    );
  }
}
