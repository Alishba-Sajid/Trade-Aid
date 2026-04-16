import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class Avatar extends StatelessWidget {
  final double radius;

  const Avatar({super.key, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: accent,
      child: const Icon(Icons.person, color: Colors.white),
    );
  }
}
