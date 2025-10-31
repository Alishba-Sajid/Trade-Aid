import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'select_community.dart';
import 'dashboard.dart'; // 👈 import your dashboard screen

const Color kPrimaryTeal = Color(0xFF004D40);
const Color kSkyBlue = Color(0xFF9ECFD4);

class CreateCommunityScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const CreateCommunityScreen({super.key, this.latitude, this.longitude});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createCommunity() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    if (widget.latitude == null || widget.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not available")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // ✅ Fixed URL to match server route
    final url = Uri.parse("http://192.168.18.29:5000/api/communities/community");

    final body = jsonEncode({
      'name': name,
      'description': desc,
      'lat': widget.latitude,
      'lon': widget.longitude,
    });
    print('Posting create community: $body to $url');

    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body);

        final randomId = Random().nextInt(900000) + 100000;
        final inviteLink = "https://tradeaid.app/community/$randomId";

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              "Community \"${data['name']}\" Created!",
              style: const TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Your community has been created successfully."),
                const SizedBox(height: 10),
                const Text(
                  "Here’s your invite link:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kSkyBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    inviteLink,
                    style: const TextStyle(
                      color: kPrimaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
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
                  label: const Text(
                    "Copy Link",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog first

                  Future.microtask(() {
                    Navigator.of(context, rootNavigator: true).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                        settings: RouteSettings(arguments: {
                          'communityName': _nameController.text.trim(),
                        }),
                      ),
                    );
                  });
                },
                child: const Text(
                  "Go to Dashboard",
                  style: TextStyle(color: kPrimaryTeal),
                ),
              ),
            ],
          ),
        );
      } else if (resp.statusCode == 409) {
        final data = jsonDecode(resp.body);
        final existing = data['existing'];

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('A community already exists nearby: ${existing['name']}')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SelectCommunityScreen(
              latitude: widget.latitude!,
              longitude: widget.longitude!,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating community: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      print('Create community error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create Community",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryTeal,
        centerTitle: true,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Create a Community of Your Own",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTeal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Community Name",
                prefixIcon: const Icon(Icons.group, color: kPrimaryTeal),
                filled: true,
                fillColor: kSkyBlue.withOpacity(0.15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: kPrimaryTeal, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Description",
                prefixIcon: const Icon(Icons.description, color: kPrimaryTeal),
                filled: true,
                fillColor: kSkyBlue.withOpacity(0.15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: kPrimaryTeal, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: kPrimaryTeal))
                    : ElevatedButton(
                        onPressed: _createCommunity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          "Create Community",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
