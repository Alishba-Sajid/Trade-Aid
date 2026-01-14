import 'dart:convert'; //ignore: unused_import
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //ignore: unused_import

/// =======================
/// PREMIUM COLOR PALETTE
/// =======================
class AppColors {
  static const Color darkPrimary = Color(0xFF004D40);
  static const Color backgroundLight = Color(0xFFF0F9F8);
  static const Color accentTeal = Color(0xFF119E90);
  static const Color subtleGrey = Color(0xFFE0E0E0);

  static const LinearGradient appGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 15, 119, 124),
      Color.fromARGB(255, 17, 158, 144),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// =======================
/// MODEL FOR USER REQUEST
/// =======================
class UserRequest {
  final String name;
  final String location;
  final double rating;

  UserRequest({
    required this.name,
    required this.location,
    required this.rating,
  });

  factory UserRequest.fromJson(Map<String, dynamic> json) {
    return UserRequest(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}

/// =======================
/// PENDING REQUESTS SCREEN
/// =======================
class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  List<UserRequest> requests = [];

  @override
  void initState() {
    super.initState();
    // For now, using dummy data. Later replace with fetchRequests()
    requests = [
      UserRequest(name: 'Ahmed Khan', location: 'House245, Gulberg, Lahore', rating: 4.5),
      UserRequest(name: 'Sara Ali', location: 'House246, Gulberg, Lahore', rating: 5.0),
    ];
    // fetchRequests(); // Uncomment when backend is ready
  }

  // Example API fetch (uncomment when ready)
  /*
  Future<void> fetchRequests() async {
    final response = await http.get(Uri.parse('https://yourapi.com/requests'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        requests = data.map((e) => UserRequest.fromJson(e)).toList();
      });
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _RequestCard(
                  data: request,
                  onAccept: () => _showConfirmDialog(
                    context,
                    title: 'Accept Request',
                    message: 'Do you really want to accept ${request.name} request?',
                    confirmText: 'Accept',
                    isAccept: true,
                  ),
                  onReject: () => _showConfirmDialog(
                    context,
                    title: 'Reject Request',
                    message: 'Do you really want to reject ${request.name} request?',
                    confirmText: 'Reject',
                    isAccept: false,
                  ),
                  onProfileTap: () => _showProfileDialog(context, request),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(gradient: AppColors.appGradient),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Pending Requests',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required bool isAccept,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkPrimary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.darkPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isAccept ? null : const Color.fromARGB(255, 164, 10, 10),
                        gradient: isAccept ? AppColors.appGradient : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isAccept
                                    ? 'Request accepted successfully'
                                    : 'Request rejected successfully',
                              ),
                              backgroundColor: isAccept
                                  ? AppColors.accentTeal
                                  : const Color.fromARGB(255, 164, 10, 10),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, UserRequest data) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Blur background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
            // Centered dialog
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: AppColors.appGradient,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                         
                        ),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person,
                              size: 45, color: AppColors.accentTeal),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            data.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Ratings
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < data.rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Location
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: AppColors.darkPrimary),
                              const SizedBox(width: 4),
                              Text(
                                data.location,
                                style: TextStyle(
                                  color: AppColors.darkPrimary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.appGradient.colors.first,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 50),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
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
      ),
    );
  }
}

/// =======================
/// REQUEST CARD
/// =======================
class _RequestCard extends StatelessWidget {
  final UserRequest data;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onProfileTap;

  const _RequestCard({
    required this.data,
    required this.onAccept,
    required this.onReject,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: onProfileTap,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.subtleGrey,
                    child: Icon(Icons.person, color: AppColors.accentTeal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkPrimary),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              data.location,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Decline',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.appGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
