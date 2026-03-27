// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trade_aid_app/services/auth_flow.dart';

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
    await Future.delayed(const Duration(seconds: 3));

    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (session == null) {
        if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
        return;
      }

      final userId = session.user.id;

      if (!mounted) return;

      // ✅ THIS is the only thing you do now
      await AuthFlow.handle(context, userId);
    } catch (e) {
      debugPrint('Error in session check: $e');
      if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Preserve your original splash screen UI
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
