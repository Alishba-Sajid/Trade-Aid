import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF0B2F2A), Color(0xFF119E90)],
);

const Color tealBackground = Color(0xFFE0F2F1);
const Color tealDark = Color(0xFF00695C);

class ResourceDetailScreen extends StatefulWidget {
  final dynamic resourceId; // ✅ changed to dynamic (safer)

  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  State<ResourceDetailScreen> createState() =>
      _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? resource;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResource();
  }

  Future<void> fetchResource() async {
    try {
      final response = await supabase
    .from('resource_view') // ✅ USE SAME VIEW
    .select()
    .eq('id', widget.resourceId)
    .maybeSingle(); // ✅ FIXED (no crash)

      debugPrint("RESOURCE DETAIL DATA: $response");

      setState(() {
        resource = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");

      setState(() {
        isLoading = false; // ✅ stop loading even if error
      });
    }
  }

  String _getDays(dynamic days) {
    if (days == null) return 'Not set';

    if (days is List) {
      return days.isNotEmpty ? days.join(", ") : 'Not set';
    }

    final parsed =
        days.toString().replaceAll('[', '').replaceAll(']', '');

    return parsed.isNotEmpty ? parsed : 'Not set';
  }

  @override
  Widget build(BuildContext context) {
    // 🔄 LOADING
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ❌ NO DATA FOUND
    if (resource == null) {
      return const Scaffold(
        body: Center(child: Text("No data found")),
      );
    }

    return Scaffold(
      backgroundColor: tealBackground,
      body: Column(
        children: [

          /// HEADER
          Container(
            height: 70,
            decoration: const BoxDecoration(gradient: appGradient),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Resource Detail",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// BODY
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                children: [

                  /// IMAGE
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        (resource!['images'] != null &&
                                resource!['images'].length > 0)
                            ? resource!['images'][0]
                            : 'https://picsum.photos/300',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),

                  /// DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text(
                          resource!['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: tealDark,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Rs ${resource!['rate'] ?? 0}",
                          style: const TextStyle(fontSize: 25),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          resource!['description'] ?? 'No description',
                          style: const TextStyle(fontSize: 25),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Available Days: ${_getDays(resource!['available_days'])}",
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}