import 'dart:ui';
import 'package:flutter/material.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: NetworkImage('https://i.pravatar.cc/600?img=11'), fit: BoxFit.cover),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          Positioned(
            top: 100,
            right: 20,
            child: Container(
              width: 110,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 2),
                image: const DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?img=3'), fit: BoxFit.cover),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: Colors.white.withOpacity(0.15),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 30),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 65,
                            width: 65,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                            child: const Icon(Icons.call_end, color: Colors.white, size: 30),
                          ),
                        ),
                        const SizedBox(width: 30),
                        const Icon(Icons.videocam_rounded, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}