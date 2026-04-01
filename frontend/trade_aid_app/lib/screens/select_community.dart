// lib/screens/select_community.dart
import 'package:flutter/material.dart';
import 'create_community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ Animated card widget
class AnimatedCard extends StatefulWidget {
  final String message;
  final IconData? icon;
  const AnimatedCard({super.key, required this.message, this.icon});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF119E90)),
            ),
            child: Row(
              children: [
                if (widget.icon != null)
                  Icon(widget.icon, color: const Color(0xFF119E90)),
                if (widget.icon != null) const SizedBox(width: 10),
                Expanded(child: Text(widget.message)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SelectCommunityScreen extends StatefulWidget {
  const SelectCommunityScreen({super.key});

  @override
  State<SelectCommunityScreen> createState() => _SelectCommunityScreenState();
}

class _SelectCommunityScreenState extends State<SelectCommunityScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> nearbyCommunities = [];
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      nearbyCommunities = List<Map<String, dynamic>>.from(
        args['nearbyCommunities'] ?? [],
      );
    }
  }

  void _showAnimatedCard(String message, {IconData? icon}) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 20,
        right: 20,
        child: AnimatedCard(message: message, icon: icon),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  // =========================
  // ✅ FIXED JOIN LOGIC
  // =========================
  Future<void> joinCommunity(Map<String, dynamic> community) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      _showAnimatedCard(
        'You must be logged in to join a community',
        icon: Icons.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Check if already a member
      final memberCheck = await supabase
          .from('community_members')
          .select()
          .eq('community_id', community['id'])
          .eq('user_id', userId)
          .maybeSingle();

      if (memberCheck != null) {
        _showAnimatedCard(
          'You are already a member of this community',
          icon: Icons.info,
        );
        return;
      }

      // ✅ Check existing request (ANY status)
      final existingRequest = await supabase
          .from('community_join_requests')
          .select()
          .eq('community_id', community['id'])
          .eq('requester_id', userId)
          .maybeSingle();

      if (existingRequest != null) {
        final status = existingRequest['status'];

        // 🔒 Already pending
        if (status == 'pending') {
          _showAnimatedCard(
            'You already requested to join this community',
            icon: Icons.info,
          );
          return;
        }

        // 🔁 Previously rejected → UPDATE instead of INSERT
        if (status == 'rejected') {
          final updateRes = await supabase
              .from('community_join_requests')
              .update({'status': 'pending'})
              .eq('id', existingRequest['id'])
              .select();

          if (updateRes.isNotEmpty) {
            _showAnimatedCard(
              'Request sent again to "${community['name']}"',
              icon: Icons.refresh,
            );
          } else {
            _showAnimatedCard('Failed to resend request', icon: Icons.error);
          }
          return;
        }
      }

      // ✅ Fresh insert
      final response = await supabase
          .from('community_join_requests')
          .insert({
            'community_id': community['id'],
            'requester_id': userId,
            'status': 'pending',
          })
          .select()
          .maybeSingle();

      if (response != null) {
        _showAnimatedCard(
          'Request sent to join "${community['name']}"',
          icon: Icons.check,
        );
      } else {
        _showAnimatedCard('Failed to send join request', icon: Icons.error);
      }
    } catch (e) {
      debugPrint('Error sending join request: $e');
      _showAnimatedCard('Failed to send join request', icon: Icons.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool noCommunitiesNearby = nearbyCommunities.isEmpty;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F777C), Color(0xFF119E90)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 150),
              const Icon(
                Icons.location_city_rounded,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Your Community',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                noCommunitiesNearby
                    ? 'No communities found near your location.'
                    : 'Choose a community from the list below.',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 40),

              if (!noCommunitiesNearby)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: nearbyCommunities.map((community) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(community['name']),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF119E90),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () => joinCommunity(community),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text('Join'),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

              if (noCommunitiesNearby)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateCommunityScreen(),
                      ),
                    );
                  },
                  child: const Text('Create Community'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
