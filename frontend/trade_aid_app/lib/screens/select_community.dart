import 'package:flutter/material.dart';
import 'create_community.dart'; // your community creation screen file

class SelectCommunityScreen extends StatefulWidget {
  const SelectCommunityScreen({super.key});

  @override
  State<SelectCommunityScreen> createState() => _SelectCommunityScreenState();
}

class _SelectCommunityScreenState extends State<SelectCommunityScreen> {
  bool noCommunitiesNearby = true; // set true if no communities found

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // keep your existing theme
      appBar: AppBar(
        title: const Text("Select Community"),
        backgroundColor: Colors.teal, // match your theme color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: noCommunitiesNearby
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "No communities found near your location.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateCommunityScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_location_alt_rounded),
                      label: const Text("Create Your Own Community"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: [
                    // Here you will show communities found in radius
                  ],
                ),
        ),
      ),
    );
  }
}
