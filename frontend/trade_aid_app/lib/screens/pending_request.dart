import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// =======================
/// COLORS
/// =======================
class AppColors {
  static const Color darkPrimary = Color(0xFF004D40);
  static const Color backgroundLight = Color(0xFFF0F9F8);
  static const Color accentTeal = Color(0xFF119E90);

  static const LinearGradient appGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 15, 119, 124),
      Color.fromARGB(255, 17, 158, 144),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// =======================
/// MODEL
/// =======================
class UserRequest {
  final String id;
  final String name;
  final String location;
  final double rating;

  UserRequest({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
  });
}

/// =======================
/// PENDING REQUESTS SCREEN
/// =======================
class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  List<UserRequest> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  /// =======================
  /// FETCH PENDING REQUESTS (JOINED)
  /// =======================
  Future<void> fetchRequests() async {
    setState(() => loading = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          requests = [];
          loading = false;
        });
        return;
      }

      final userId = user.id;

      // 1️⃣ Get communities owned by this user
      final ownedCommunities = await supabase
          .from('communities')
          .select('id')
          .eq('creator_id', userId);

      final communityIds = (ownedCommunities as List)
          .map((e) => e['id'].toString())
          .toList();

      debugPrint('Owned community IDs: $communityIds');

      if (communityIds.isEmpty) {
        setState(() {
          requests = [];
          loading = false;
        });
        return;
      }

      // 2️⃣ Fetch pending requests with profile info
      final pendingRequests = await supabase
          .from('community_requests')
          .select(
            'id, status, created_at, user_id, profiles!inner(full_name, address)',
          )
          .filter(
            'community_id',
            'in',
            communityIds,
          ) // ✅ pass List<String> directly
          .eq('status', 'pending');

      debugPrint('Pending requests raw: $pendingRequests');

      final List<UserRequest> tempRequests = [];

      for (var req in pendingRequests) {
        tempRequests.add(
          UserRequest(
            id: req['id'].toString(),
            name: req['profiles']['full_name'] ?? 'Unknown',
            location: req['profiles']['address'] ?? '',
            rating: 0,
          ),
        );
      }

      setState(() {
        requests = tempRequests;
        loading = false;
      });
    } catch (e, st) {
      debugPrint('Error fetching requests: $e\n$st');
      setState(() {
        requests = [];
        loading = false;
      });
    }
  }

  /// =======================
  /// UPDATE REQUEST STATUS
  /// =======================
  Future<void> updateRequestStatus(String requestId, bool accept) async {
    try {
      await Supabase.instance.client
          .from('community_requests')
          .update({'status': accept ? 'approved' : 'rejected'})
          .eq('id', requestId);

      fetchRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Request accepted' : 'Request rejected'),
          backgroundColor: accept
              ? AppColors.accentTeal
              : const Color.fromARGB(255, 164, 10, 10),
        ),
      );
    } catch (e) {
      debugPrint('Error updating request status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update request'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// =======================
  /// UI
  /// =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          _buildHeader(context),
          loading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: requests.isEmpty
                      ? const Center(child: Text('No pending requests'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            return _RequestCard(
                              data: request,
                              onAccept: () =>
                                  updateRequestStatus(request.id, true),
                              onReject: () =>
                                  updateRequestStatus(request.id, false),
                              onProfileTap: () =>
                                  _showProfileDialog(context, request),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.appGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Text(
                'Pending Requests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, UserRequest data) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: AppColors.appGradient,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 45,
                            color: AppColors.accentTeal,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            data.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < data.rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.darkPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                data.location,
                                style: TextStyle(
                                  color: AppColors.darkPrimary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.appGradient.colors.first,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 50,
                              ),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// REQUEST CARD
/// =======================
class _RequestCard extends StatelessWidget {
  final UserRequest data;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onProfileTap;

  const _RequestCard({
    required this.data,
    required this.onAccept,
    required this.onReject,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: onProfileTap,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, color: AppColors.accentTeal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              data.location,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showConfirmDialog(
                        context,
                        title: 'Reject Request',
                        message:
                            'Do you really want to reject ${data.name} request?',
                        confirmText: 'Reject',
                        isAccept: false,
                        onConfirm: onReject,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.appGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _showConfirmDialog(
                          context,
                          title: 'Accept Request',
                          message:
                              'Do you really want to accept ${data.name} request?',
                          confirmText: 'Accept',
                          isAccept: true,
                          onConfirm: onAccept,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required bool isAccept,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.darkPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isAccept
                            ? null
                            : const Color.fromARGB(255, 164, 10, 10),
                        gradient: isAccept ? AppColors.appGradient : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
