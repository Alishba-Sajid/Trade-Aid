import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class UserRequest {
  final String id;
  final String name;
  final String location;
  final double rating;
  final String communityId;
  final String requesterId;
  final String? profileImageUrl;

  UserRequest({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.communityId,
    required this.requesterId,
    required this.profileImageUrl,
  });
}

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  List<UserRequest> requests = [];
  bool loading = true;

  /// Track which request is being processed (approve)
  String? _processingRequestId;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

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

      if (communityIds.isEmpty) {
        setState(() {
          requests = [];
          loading = false;
        });
        return;
      }

      // 2️⃣ Fetch pending requests with profile info
      final pendingRequests = await supabase
          .from('community_join_requests')
          .select(
            'id, status, created_at, requester_id, community_id, requester:profiles(full_name, address, profile_image_url)',
          )
          .inFilter('community_id', communityIds)
          .eq('status', 'pending');

      final List<UserRequest> tempRequests = [];

      for (var req in pendingRequests) {
        final requester = (req['requester'] as Map?)?.cast<String, dynamic>();
        tempRequests.add(
          UserRequest(
            id: req['id'].toString(),
            name: requester?['full_name'] ?? 'Unknown',
            location: requester?['address'] ?? '',
            rating: 0,
            communityId: req['community_id'],
            requesterId: req['requester_id'],
            profileImageUrl: requester?['profile_image_url'],
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
  /// Approve with per-request loading
  /// =======================
  Future<void> approveRequest(UserRequest req) async {
    final supabase = Supabase.instance.client;

    try {
      setState(() {
        _processingRequestId = req.id;
      });

      // Insert user into community_members
      await supabase.from('community_members').insert({
        'community_id': req.communityId,
        'user_id': req.requesterId,
        'role': 'member',
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Update join request status
      await supabase
          .from('community_join_requests')
          .update({'status': 'approved'})
          .eq('id', req.id);

      // Remove from UI list
      setState(() {
        requests.removeWhere((r) => r.id == req.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User added to community!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error approving request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to approve request'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _processingRequestId = null;
      });
    }
  }

  Future<void> rejectRequest(UserRequest req) async {
    try {
      await Supabase.instance.client
          .from('community_join_requests')
          .update({'status': 'rejected'})
          .eq('id', req.id);

      setState(() {
        requests.removeWhere((r) => r.id == req.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request rejected'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      debugPrint('Error rejecting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject request'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

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
                            final req = requests[index];
                            return _RequestCard(
                              data: req,
                              onAccept: () => approveRequest(req),
                              onReject: () => rejectRequest(req),
                              onProfileTap: () =>
                                  _showProfileDialog(context, req),
                              processingRequestId: _processingRequestId,
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
                      child: Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: (data.profileImageUrl != null &&
                                  data.profileImageUrl!.trim().isNotEmpty)
                              ? NetworkImage(data.profileImageUrl!.trim())
                              : null,
                          child: (data.profileImageUrl != null &&
                                  data.profileImageUrl!.trim().isNotEmpty)
                              ? null
                              : const Icon(
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

class _RequestCard extends StatelessWidget {
  final UserRequest data;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onProfileTap;
  final String? processingRequestId;

  const _RequestCard({
    required this.data,
    required this.onAccept,
    required this.onReject,
    required this.onProfileTap,
    required this.processingRequestId,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = data.profileImageUrl?.trim();
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
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFFE0E0E0),
                    backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                        ? NetworkImage(imageUrl)
                        : null,
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? null
                        : const Icon(
                            Icons.person,
                            color: AppColors.accentTeal,
                          ),
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
                    onPressed: onReject,
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
                      onPressed: processingRequestId == data.id
                          ? null
                          : onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: processingRequestId == data.id
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
}
