import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
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
