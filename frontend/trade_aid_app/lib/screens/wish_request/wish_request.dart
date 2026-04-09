import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'post_wish_request.dart';
import '../../widgets/app_bar.dart';
import '../chat/chat_screen.dart';

// 🎨 COLORS
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color backgroundLight = Color(0xFFF4F6F9);
const Color darkPrimary = Color(0xFF0F777C);
const Color accentTeal = Color(0xFF119E90);

class WishRequestsScreen extends StatefulWidget {
  final String communityId;

  const WishRequestsScreen({super.key, required this.communityId});

  @override
  State<WishRequestsScreen> createState() => _WishRequestsScreenState();
}

class _WishRequestsScreenState extends State<WishRequestsScreen> {
  List<Map<String, dynamic>> requests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCommunityWishRequests();
  }

  Future<void> _fetchCommunityWishRequests() async {
    setState(() => loading = true);

    try {
      final supabase = Supabase.instance.client;

      final data = await supabase
          .from('wish_requests')
          .select('id,item_name,description,urgent,user_id,created_at')
          .eq('community_id', widget.communityId)
          .gte(
            'created_at',
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          )
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(data);

      debugPrint("Fetched wish requests: ${dataList.length}");

      final mapped = await Future.wait(
        dataList.map((r) async {
          final profile = await supabase
              .from('profiles')
              .select('full_name')
              .eq('user_id', r['user_id'])
              .maybeSingle();

          return {
            'id': r['id'],
            'requester': profile?['full_name'] ?? 'Unknown',
            'requesterId': r['user_id'],
            'item': r['item_name'],
            'description': r['description'],
            'urgency': r['urgent'] == true ? 'High' : 'Normal',
            'timeAgo': _formatTimeAgo(DateTime.parse(r['created_at'])),
          };
        }).toList(),
      );

      setState(() {
        requests = mapped;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching requests: $e");
      setState(() {
        requests = [];
        loading = false;
      });
    }
  }

  String _formatTimeAgo(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} mins ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hours ago";
    } else {
      return "${diff.inDays} days ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBarWidget(
        title: 'Wish Requests',
        onBack: () => Navigator.pop(context),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text("No requests in your community"))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
              itemCount: requests.length,
              itemBuilder: (context, index) =>
                  _buildRequestCard(requests[index]),
            ),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: appGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PostWishRequestScreen(communityId: widget.communityId),
                ),
              ).then((_) => _fetchCommunityWishRequests());
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Post Request',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    bool isHighUrgency = request['urgency'] == 'High';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkPrimary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                color: isHighUrgency ? Colors.orangeAccent : accentTeal,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Requester row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: backgroundLight,
                                child: Text(
                                  request['requester'][0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: darkPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                request['requester'],
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            request['timeAgo'],
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// Wish Item
                      Text(
                        "Wish: ${request['item']}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Description
                      Text(
                        request['description'] ?? "",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                showDialog<bool>(
                                  context: context,
                                  builder: (context) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color.fromARGB(255, 15, 119, 124),
                                            Color.fromARGB(255, 17, 158, 144),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            /// 🔥 Icon
                                            Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                gradient: appGradient,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.public,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),

                                            const SizedBox(height: 16),

                                            /// 📝 Title
                                            const Text(
                                              "Make Product Public?",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: darkPrimary,
                                              ),
                                            ),

                                            const SizedBox(height: 10),

                                            /// 📄 Description
                                            Text(
                                              "Do you want to make this product public after 48 hours?",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                height: 1.4,
                                              ),
                                            ),

                                            const SizedBox(height: 24),

                                            /// 🎯 Buttons
                                            Row(
                                              children: [
                                                /// ❌ NO BUTTON
                                                Expanded(
                                                  child: Container(
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color: accentTeal,
                                                      ),
                                                    ),
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        Navigator.pushNamed(
                                                          context,
                                                          '/product_post',
                                                          arguments: {
                                                            'wishId':
                                                                request['id'],
                                                            'makePublicAfter48Hours':
                                                                false,
                                                            'communityId': widget
                                                                .communityId,
                                                            'requesterId':
                                                                request['requesterId'],
                                                          },
                                                        );
                                                      },
                                                      child: const Center(
                                                        child: Text(
                                                          "No",
                                                          style: TextStyle(
                                                            color: accentTeal,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 12),

                                                /// ✅ YES BUTTON
                                                Expanded(
                                                  child: Container(
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                      gradient: appGradient,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.pushNamed(
                                                          context,
                                                          '/product_post',
                                                          arguments: {
                                                            'wishId':
                                                                request['id'],
                                                            'makePublicAfter48Hours':
                                                                true,
                                                            'communityId': widget
                                                                .communityId,
                                                            'requesterId':
                                                                request['requesterId'],
                                                          },
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        shadowColor:
                                                            Colors.transparent,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        "Yes",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentTeal.withOpacity(0.1),
                                foregroundColor: accentTeal,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                "Upload Product",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          _buildSmallIconButton(Icons.chat_bubble_outline, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  sellerName: request['requester'],
                                  receiverId: request['requesterId'],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: darkPrimary, size: 20),
      ),
    );
  }
}
