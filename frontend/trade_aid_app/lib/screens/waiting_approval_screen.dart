import 'package:flutter/material.dart';

class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Approval Pending")),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "Your request is pending approval from the community creator.\n\nPlease wait.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
