// lib/screens/select_community.dart
import 'package:flutter/material.dart';
import 'create_community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ Animated card widget (same as other screens)
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
                if (widget.icon != null)
                  Icon(
                    widget.icon,
                    color: const Color.fromARGB(255, 17, 158, 144),
                  ),
                if (widget.icon != null) const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
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

  // ✅ Animated card helper
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
  // ✅ Step 1: Send Join Request
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

      final existingRequest = await supabase
          .from('community_join_requests')
          .select()
          .eq('community_id', community['id'])
          .eq('requester_id', userId)
          .maybeSingle();

      if (existingRequest != null) {
        _showAnimatedCard(
          'You already requested to join this community',
          icon: Icons.info,
        );
        return;
      }

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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 15, 119, 124),
              Color.fromARGB(255, 17, 158, 144),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                noCommunitiesNearby
                    ? 'No communities found near your location.'
                    : 'Choose a community from the list below.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (!noCommunitiesNearby)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: nearbyCommunities.map((community) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  community['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => joinCommunity(community),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Join',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
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
                SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateCommunityScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_location_alt_rounded,
                      color: Colors.teal,
                    ),
                    label: const Text(
                      'Create Community',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
