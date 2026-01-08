import 'package:flutter/material.dart';

class SocialAuthSection extends StatelessWidget {
  final String title;

  const SocialAuthSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(title, style: const TextStyle(color: Colors.grey)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _SocialButton(icon: Icons.facebook, color: Colors.blue),
            _SocialButton(
              icon: Icons.g_mobiledata,
              color: Color.fromARGB(255, 171, 30, 20),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SocialButton({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withOpacity(0.1),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: () {
          // TODO: connect social auth
        },
      ),
    );
  }
}
