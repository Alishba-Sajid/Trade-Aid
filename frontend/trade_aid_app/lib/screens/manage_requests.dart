import 'package:flutter/material.dart';

// keep the same shared colors you already have
const Color kPrimaryTeal = Color(0xFF004D40);
const Color kLightTeal = Color(0xFF70B2B2);
const Color kSkyBlue = Color(0xFF9ECFD4);

class ManageRequestsScreen extends StatelessWidget {
  const ManageRequestsScreen({super.key});

  // sample placeholder data — replace with backend data
  final List<Map<String, String>> _sampleRequests = const [
    {
      'id': '1',
      'name': 'Aisha Khan',
      'location': 'GG-12, Block B',
      'avatar':
          'https://via.placeholder.com/150' // replace with real avatar url from backend
    },
    {
      'id': '2',
      'name': 'Bilal Ahmed',
      'location': 'GG-13, Block C',
      'avatar': 'https://via.placeholder.com/150'
    },
    {
      'id': '3',
      'name': 'Sara Ali',
      'location': 'GG-14, Block A',
      'avatar': 'https://via.placeholder.com/150'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // NOTE: In real app, replace _sampleRequests with your async backend call results.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Join Requests'),
        centerTitle: true,
        backgroundColor: kPrimaryTeal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _sampleRequests.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.person_off, size: 56, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No pending requests', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: _sampleRequests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final req = _sampleRequests[index];
                  return RequestTile(
                    avatarUrl: req['avatar']!,
                    name: req['name']!,
                    location: req['location']!,
                    // provide callbacks for accept/reject — currently placeholders
                    onAccept: () {
                     
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${req['name']} accepted')),
                      );
                    },
                    onReject: () {
                     
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${req['name']} rejected')),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class RequestTile extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String location;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const RequestTile({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.location,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kSkyBlue.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // profile image
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(avatarUrl),
            child: avatarUrl.isEmpty ? const Icon(Icons.person, color: kPrimaryTeal) : null,
          ),
          const SizedBox(width: 12),

          // name + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.black45),
                    const SizedBox(width: 4),
                    Expanded(child: Text(location, style: const TextStyle(color: Colors.black54))),
                  ],
                ),
              ],
            ),
          ),

          // accept / reject icons
          Row(
            children: [
              // accept
              IconButton(
                onPressed: onAccept,
                icon: const Icon(Icons.check_circle, size: 28),
                color: Colors.green,
                tooltip: 'Accept',
              ),
              // reject
              IconButton(
                onPressed: onReject,
                icon: const Icon(Icons.cancel, size: 28),
                color: Colors.red,
                tooltip: 'Reject',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
