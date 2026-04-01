import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ✅ AuthFlow with animated cards, works for email & Google logins
class AuthFlow {
  /// Show animated card overlay (SAFE)
  static void _showAnimatedCard(
    GlobalKey<NavigatorState> navigatorKey,
    String message, {
    IconData? icon,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 20,
        right: 20,
        child: _AnimatedCard(message: message, icon: icon),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  /// ✅ Main auth handler (NO context issues anymore)
  static Future<void> handle(
    GlobalKey<NavigatorState> navigatorKey,
    String userId,
  ) async {
    final supabase = Supabase.instance.client;

    try {
      // ✅ Check if profile exists
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (profile == null) {
        navigatorKey.currentState?.pushReplacementNamed('/create_profile');

        Future.delayed(const Duration(milliseconds: 300), () {
          _showAnimatedCard(
            navigatorKey,
            "Please create your profile to continue.",
            icon: Icons.person_add,
          );
        });
        return;
      }

      // ✅ Check if user is already in a community
      final membership = await supabase
          .from('community_members')
          .select('community_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (membership != null) {
        navigatorKey.currentState?.pushReplacementNamed('/dashboard');
        return;
      }

      // ✅ Check if request is pending
      final pendingRequest = await supabase
          .from('community_join_requests')
          .select()
          .eq('requester_id', userId)
          .eq('status', 'pending')
          .maybeSingle();

      if (pendingRequest != null) {
        navigatorKey.currentState?.pushReplacementNamed(
          '/login',
        ); // stay safe screen

        Future.delayed(const Duration(milliseconds: 300), () {
          _showAnimatedCard(
            navigatorKey,
            "Your request is still pending approval. Please wait.",
            icon: Icons.info_outline,
          );
        });

        return;
      }

      // ✅ Check if request was rejected
      final rejectedRequest = await supabase
          .from('community_join_requests')
          .select()
          .eq('requester_id', userId)
          .eq('status', 'rejected')
          .maybeSingle();

      if (rejectedRequest != null) {
        // Delete the rejected request to prevent repeated snackbars
        await supabase
            .from('community_join_requests')
            .delete()
            .eq('id', rejectedRequest['id']);

        // Show rejection snackbar on current screen
        Future.delayed(const Duration(milliseconds: 300), () {
          _showAnimatedCard(
            navigatorKey,
            "Your request has been rejected. Please try again.",
            icon: Icons.error_outline,
          );
        });

        // Delay navigation to allow snackbar to show, then navigate and show location snackbar
        Future.delayed(const Duration(seconds: 2), () {
          navigatorKey.currentState?.pushReplacementNamed(
            '/location_permission',
          );
          Future.delayed(const Duration(milliseconds: 300), () {
            _showAnimatedCard(
              navigatorKey,
              "Please allow location permission to continue.",
              icon: Icons.location_on,
            );
          });
        });
        return;
      }

      // ✅ If profile exists but not in a community
      navigatorKey.currentState?.pushReplacementNamed('/location_permission');

      Future.delayed(const Duration(milliseconds: 300), () {
        _showAnimatedCard(
          navigatorKey,
          "Please allow location permission to continue.",
          icon: Icons.location_on,
        );
      });
    } catch (e) {
      debugPrint("Auth flow error: $e");
      navigatorKey.currentState?.pushReplacementNamed('/welcome');
    }
  }
}

/// ✅ AnimatedCard widget (UNCHANGED)
class _AnimatedCard extends StatefulWidget {
  final String message;
  final IconData? icon;
  const _AnimatedCard({required this.message, this.icon});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
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
