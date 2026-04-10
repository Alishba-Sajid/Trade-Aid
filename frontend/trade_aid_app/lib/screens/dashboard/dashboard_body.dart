import 'package:flutter/material.dart';
import 'community_dialog.dart';
import '../wish_request/wish_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🌿 Premium Color Constants
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Color dark = Color(0xFF004D40);
const Color light = Color(0xFFF0F9F8);
const Color accent = Color(0xFF119E90);

// =========================
// Dashboard Body
// =========================
class DashboardBody extends StatefulWidget {
  final String userName;
  final String communityName;
  final String communityId;
  final bool isAdmin;

  const DashboardBody({
    super.key,
    required this.userName,
    required this.communityName,
    required this.communityId,
    required this.isAdmin,
  });

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  RealtimeChannel? wishChannel;
  RealtimeChannel? communityChannel;

  int activeWishCount = 0;
  List<Map<String, dynamic>> nearbyCommunities = [];

  bool locationPermissionGranted = false;
  bool locationDeniedForever = false;
  bool loadingNearby = true;

  void _subscribeWishRequests() {
    wishChannel?.unsubscribe();

    final supabase = Supabase.instance.client;

    wishChannel = supabase.channel('wish_requests_channel')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'wish_requests',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'community_id',
          value: widget.communityId,
        ),
        callback: (payload) {
          if (!mounted) return;

          _fetchActiveWishCount();
        },
      )
      ..subscribe();
  }

  void _subscribeNearbyCommunities() {
    final supabase = Supabase.instance.client;

    communityChannel = supabase.channel('community_channel')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'communities',
        callback: (payload) {
          _fetchNearbyCommunities();
        },
      )
      ..subscribe();
  }

  Future<void> _loadDashboardData() async {
    await _fetchActiveWishCount();
    await _fetchNearbyCommunities();
  }

  Future<void> _initializeDashboard() async {
    final supabase = Supabase.instance.client;

    final session = supabase.auth.currentSession;

    if (session != null) {
      // Load existing dashboard data
      await _loadDashboardData();

      // Start realtime listeners
      _subscribeWishRequests();
      _subscribeNearbyCommunities();
    } else {
      supabase.auth.onAuthStateChange.listen((data) async {
        if (data.event == AuthChangeEvent.signedIn) {
          // Load existing records first
          await _loadDashboardData();

          // Then listen for new realtime events
          _subscribeWishRequests();
          _subscribeNearbyCommunities();
        }
      });
    }
  }

  Future<void> _fetchActiveWishCount() async {
    if (widget.communityId.isEmpty) return;

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('wish_requests')
          .select('id')
          .eq('community_id', widget.communityId)
          .gte(
            'created_at',
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          );

      if (!mounted) return;

      setState(() {
        activeWishCount = (response as List).length;
      });
    } catch (e) {
      debugPrint("Error fetching wish count: $e");
    }
  }

  Future<void> _fetchNearbyCommunities() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return;

      final profile = await supabase
          .from('profiles')
          .select('home_latitude, home_longitude')
          .eq('user_id', userId)
          .maybeSingle();

      if (profile == null ||
          profile['home_latitude'] == null ||
          profile['home_longitude'] == null) {
        setState(() {
          loadingNearby = false;
          nearbyCommunities = [];
        });

        return;
      }

      final double userLat = profile['home_latitude'];
      final double userLng = profile['home_longitude'];

      final response = await supabase.rpc(
        'get_nearby_communities',
        params: {
          'user_lat': userLat,
          'user_lng': userLng,
          'radius_km': 1.0,
          'current_community': widget.communityId.isEmpty
              ? null
              : widget.communityId,
        },
      );

      if (!mounted) return;

      setState(() {
        loadingNearby = false;
        nearbyCommunities = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Error fetching nearby communities: $e");

      setState(() {
        loadingNearby = false;
        nearbyCommunities = [];
      });
    }
  }

  Future<void> _joinCommunity(Map<String, dynamic> community) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      _showAnimatedCard('You must be logged in to join a community');
      return;
    }

    try {
      final memberCheck = await Supabase.instance.client
          .from('community_members')
          .select()
          .eq('community_id', community['id'])
          .eq('user_id', userId)
          .maybeSingle();

      // ✅ If already a member - allow user to access/switch to this community
      if (memberCheck != null) {
        _showAnimatedCard(
          'You are already a member of "${community['name']}" ',
          icon: Icons.info,
        );
        return;
      }

      // ✅ Check if there's already a pending request
      final existingRequest = await Supabase.instance.client
          .from('community_join_requests')
          .select()
          .eq('community_id', community['id'])
          .eq('requester_id', userId)
          .maybeSingle();

      if (existingRequest != null) {
        if (existingRequest['status'] == 'pending') {
          _showAnimatedCard(
            'You already requested to join this community',
            icon: Icons.info,
          );
          return;
        }

        // 🔁 Handle rejected or old requests - allow to request again
        await Supabase.instance.client
            .from('community_join_requests')
            .update({'status': 'pending'})
            .eq('id', existingRequest['id']);

        _showAnimatedCard(
          'Request sent again to "${community['name']}" admin',
          icon: Icons.refresh,
        );
        return;
      }

      // ✅ Send join request to admin
      final response = await Supabase.instance.client
          .from('community_join_requests')
          .insert({
            'community_id': community['id'],
            'requester_id': userId,
            'status': 'pending',
          })
          .select()
          .maybeSingle();

      if (response != null) {
        _showAnimatedCard('Request sent to "${community['name']}" admin');
      } else {
        _showAnimatedCard('Failed to send join request');
      }
    } catch (e) {
      debugPrint('Error sending join request: $e');
      _showAnimatedCard('Failed to send join request');
    }
  }

  void _showAnimatedCard(String message, {IconData? icon}) {
    icon ??= Icons.check;

    if (message.contains('already') ||
        message.contains('Failed') ||
        message.contains('must be logged in')) {
      icon = Icons.error;
    } else if (message.contains('already requested')) {
      icon = Icons.info;
    }

    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 20,
        right: 20,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 17, 158, 144),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  @override
  void didUpdateWidget(covariant DashboardBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.communityId != oldWidget.communityId &&
        widget.communityId.isNotEmpty) {
      _fetchActiveWishCount();
      _fetchNearbyCommunities();
    }
  }

  @override
  void dispose() {
    wishChannel?.unsubscribe();
    communityChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================
        // Gradient Top Section (UNCHANGED UI)
        // =========================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
          decoration: const BoxDecoration(
            gradient: appGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isAdmin
                        ? 'Hello Admin 👋'
                        : 'Hello, ${widget.userName} 👋',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      CommunityDialog.show(
                        context,
                        Community(
                          id: widget.communityId,
                          name: widget.communityName,
                          description:
                              "This is your current community. All your posts, resources, and activity will appear here.",
                          isCurrent: true,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.white70, Colors.white],
                          ),
                        ),
                        child: const Icon(
                          Icons.location_city_rounded,
                          color: dark,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -2),
                    child: Text(
                      'Good to see you today',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      CommunityDialog.show(
                        context,
                        Community(
                          id: widget.communityId,
                          name: widget.communityName,
                          description:
                              "This is your current community. All your posts, resources, and activity will appear here.",
                          isCurrent: true,
                        ),
                      );
                    },
                    child: Text(
                      widget.communityName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // =========================
        // Main White Section (UNCHANGED UI)
        // =========================
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ListView(
              children: [
                _buildSectionHeader('Services'),
                const SizedBox(height: 13),

                // ✅ FUNCTIONALITY ADDED HERE ONLY
                Row(
                  children: [
                    Expanded(
                      child: _ServiceCard(
                        title: 'Products',
                        subtitle: 'Browse items',
                        icon: Icons.shopping_cart_outlined,
                        route: '/product_listing',
                        communityId: widget.communityId,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ServiceCard(
                        title: 'Resources',
                        subtitle: 'Available resources',
                        icon: Icons.group,
                        route: '/resource_listing', // ✅ FIXED
                        communityId: widget.communityId,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _buildSectionHeader('Wish Requests'),
                const SizedBox(height: 13),

                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WishRequestsScreen(
                        communityId: widget.communityId, // Pass it here
                      ),
                    ),
                  ),
                  child: _buildPremiumWishCard(),
                ),

                const SizedBox(height: 20),

                _buildSectionHeader('Nearby Communities'),
                const SizedBox(height: 13),

                SizedBox(
                  height: 130,
                  child: loadingNearby
                      ? const Center(child: CircularProgressIndicator())
                      : nearbyCommunities.isEmpty
                      ? _buildNoNearbyCommunities()
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          children: nearbyCommunities
                              .map(
                                (community) => _CommunityTile(
                                  community['name'],
                                  description: community['description'] ?? '',
                                  id: community['id'],
                                  onJoin: () => _joinCommunity(community),
                                ),
                              )
                              .toList(),
                        ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: dark,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildNoNearbyCommunities() {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 90,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.03)),
              boxShadow: [
                BoxShadow(
                  color: dark.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.location_off, size: 32, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'No nearby communities',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumWishCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: dark.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: light,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items Required',
                  style: TextStyle(
                    color: dark,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  'Urgent community needs',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$activeWishCount Active',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// Service Card (ONLY FUNCTIONAL CHANGE)
// =========================
class _ServiceCard extends StatelessWidget {
  final String title, subtitle, route;
  final IconData icon;
  final String communityId; // ✅ ADDED

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.communityId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        route,
        arguments: communityId, // ✅ PASSING COMMUNITY ID
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(
              color: dark.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: appGradient,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: dark,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// Community Tile
// =========================
class _CommunityTile extends StatelessWidget {
  final String name;
  final String description;
  final String? id;
  final VoidCallback? onJoin;

  const _CommunityTile(
    this.name, {
    required this.description,
    this.id,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 100,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              CommunityDialog.show(
                context,
                Community(
                  id: id ?? '',
                  name: name,
                  description: description, // still passed to dialog
                ),
                onJoin: onJoin,
              );
            },
            child: Container(
              height: 90,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black.withOpacity(0.03)),
                boxShadow: [
                  BoxShadow(
                    color: dark.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: light,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    size: 32,
                    color: accent,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),

          GestureDetector(
            onTap: () {
              CommunityDialog.show(
                context,
                Community(id: id ?? '', name: name, description: description),
                onJoin: onJoin,
              );
            },
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: dark,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}