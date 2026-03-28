// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Splash screen delay
    await Future.delayed(const Duration(seconds: 3));

    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (session == null) {
        // No session → first-time user → Welcome screen
        if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
        return;
      }

      final user = session.user;
      if (!mounted) return;

      // Check if user has a profile
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (profile == null) {
        // New user → Create profile screen
        if (mounted) Navigator.pushReplacementNamed(context, '/create_profile');
        return;
      }

      // Check if user is in a community
      final membership = await supabase
          .from('community_members')
          .select('community_id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (membership != null) {
        // User is in community → Dashboard
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
        return;
      }

      // Check for pending join requests
      final pending = await supabase
          .from('community_join_requests')
          .select()
          .eq('requester_id', user.id)
          .eq('status', 'pending')
          .maybeSingle();

      if (pending != null) {
        // Pending request → Login screen
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Default → Location permission
      if (mounted)
        Navigator.pushReplacementNamed(context, '/location_permission');
    } catch (e) {
      debugPrint('Error in session check: $e');
      if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', height: 180, width: 180),
                const SizedBox(height: 20),
                const Text(
                  'Trade&Aid',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pacifico',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  color: Colors.teal,
                  strokeWidth: 5,
                ),
              ],
            ),
          ),

          // Bottom copyright text
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              '© 2026 Trade&Aid. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 74, 74, 74),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
