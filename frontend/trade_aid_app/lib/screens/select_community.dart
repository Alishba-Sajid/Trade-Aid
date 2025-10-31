import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_community.dart';

const Color kPrimaryTeal = Color(0xFF004D40);

class SelectCommunityScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const SelectCommunityScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<SelectCommunityScreen> createState() => _SelectCommunityScreenState();
}

class _SelectCommunityScreenState extends State<SelectCommunityScreen> {
  bool isLoading = true;
  List<dynamic> communities = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchNearbyCommunities();
  }

  Future<void> fetchNearbyCommunities() async {
    try {
      final url = Uri.parse(
          'http://192.168.18.29:5000/api/communities?lat=${widget.latitude}&lon=${widget.longitude}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          communities = data;
          isLoading = false;
        });

        // If no community found → navigate to create screen
        if (data.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CreateCommunityScreen(
                latitude: widget.latitude,
                longitude: widget.longitude,
              ),
            ),
          );
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch communities: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryTeal)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Select Community"),
          backgroundColor: kPrimaryTeal,
        ),
        body: Center(
          child: Text(errorMessage!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Communities"),
        backgroundColor: kPrimaryTeal,
      ),
      body: ListView.builder(
        itemCount: communities.length,
        itemBuilder: (context, index) {
          final community = communities[index];
          final name = community['name'] ?? 'Unnamed';
          final description = community['description'] ?? 'No description';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(description),
              trailing: ElevatedButton(
                onPressed: () async {
                  final userId = 1; // Replace with actual user ID
                  final communityId = community['id'];

                  final joinUrl = Uri.parse(
                      'http://192.168.18.29:5000/api/communities/join');
                  final resp = await http.post(
                    joinUrl,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'user_id': userId, 'community_id': communityId}),
                  );

                  if (resp.statusCode == 201) {
                    final data = jsonDecode(resp.body);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['message'] ?? 'Request sent')),
                    );
                  } else if (resp.statusCode == 409) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Already requested to join")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${resp.statusCode}")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryTeal),
                child: const Text("Join"),
              ),
            ),
          );
        },
      ),
    );
  }
}
