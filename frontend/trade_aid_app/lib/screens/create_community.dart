import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void _createCommunity() {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    // Generate random 6-digit community ID
    final randomId = Random().nextInt(900000) + 100000;
    final inviteLink = "https://tradeaid.app/community/$randomId";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Community Created!",
          style: TextStyle(color: Colors.teal),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Your community has been created successfully."),
            const SizedBox(height: 12),
            const Text(
              "Invite Link",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              inviteLink,
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: inviteLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Link copied to clipboard")),
                );
              },
              icon: const Icon(Icons.copy, color: Colors.white),
              label: const Text("Copy Link"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context,
                '/dashboard',
                arguments: {'communityName': name},
              );
            },
            child: const Text("Go to Dashboard"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),

              Image.asset('assets/logomain.png', height: 100),
              const SizedBox(height: 70),

              const Text(
                "Create Your Community",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Trade what you have, Aid when you can",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Community Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: 260,
                child: ElevatedButton(
                  onPressed: _createCommunity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Create Community",
                    style: TextStyle(fontSize: 16),
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
