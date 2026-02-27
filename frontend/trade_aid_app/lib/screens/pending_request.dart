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

  UserRequest({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.communityId,
    required this.requesterId,
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
  bool actionInProgress = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    setState(() => loading = true);
    try {
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
            'id, status, created_at, requester_id, community_id, requester:profiles(full_name, address)',
          )
          .filter('community_id', 'in', communityIds)
          .eq('status', 'pending');

      final List<UserRequest> tempRequests = [];

      for (var req in pendingRequests) {
        tempRequests.add(
          UserRequest(
            id: req['id'].toString(),
            name: req['requester']['full_name'] ?? 'Unknown',
            location: req['requester']['address'] ?? '',
            rating: 0,
            communityId: req['community_id'],
            requesterId: req['requester_id'],
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

  Future<void> approveRequest(UserRequest req) async {
    if (actionInProgress) return;
    setState(() => actionInProgress = true);

    try {
      final userId = supabase.auth.currentUser!.id;

      // Check if already voted
      final voteCheck = await supabase
          .from('request_votes')
          .select()
          .eq('request_id', req.id)
          .eq('voter_id', userId)
          .maybeSingle();

      if (voteCheck != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already voted for this request')),
        );
        return;
      }

      // Insert vote
      await supabase.from('request_votes').insert({
        'request_id': req.id,
        'voter_id': userId,
        'vote': 'approve',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Check approval threshold
      final members = await supabase
          .from('community_members')
          .select()
          .eq('community_id', req.communityId);

      final totalMembers = members.length;
      final votes = await supabase
          .from('request_votes')
          .select()
          .eq('request_id', req.id);

      final approvedVotes = votes.length;

      if (totalMembers > 0 && approvedVotes / totalMembers >= 0.5) {
        // Add user to community
        await supabase.from('community_members').insert({
          'community_id': req.communityId,
          'user_id': req.requesterId,
          'role': 'member',
          'joined_at': DateTime.now().toIso8601String(),
        });

        // Update request status
        await supabase
            .from('community_join_requests')
            .update({'status': 'approved'})
            .eq('id', req.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User added to community!'),
            backgroundColor: AppColors.accentTeal,
          ),
        );
      }

      await fetchRequests();
    } catch (e) {
      debugPrint('Error approving request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to approve request'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => actionInProgress = false);
    }
  }

  Future<void> rejectRequest(UserRequest req) async {
    if (actionInProgress) return;
    setState(() => actionInProgress = true);

    try {
      await supabase
          .from('community_join_requests')
          .update({'status': 'rejected'})
          .eq('id', req.id);

      await fetchRequests();

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
    } finally {
      setState(() => actionInProgress = false);
    }
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
                              actionInProgress: actionInProgress,
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final UserRequest data;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onProfileTap;
  final bool actionInProgress;

  const _RequestCard({
    required this.data,
    required this.onAccept,
    required this.onReject,
    required this.onProfileTap,
    required this.actionInProgress,
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
                    onPressed: actionInProgress ? null : onReject,
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
                      onPressed: actionInProgress ? null : onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: actionInProgress
                          ? const SizedBox(
                              height: 16,
                              width: 16,
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
