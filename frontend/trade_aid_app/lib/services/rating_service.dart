import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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

// ✅ Animated Card Widget for Feedback
class AnimatedCard extends StatefulWidget {
  final String message;
  final IconData? icon;
  const AnimatedCard({super.key, required this.message, this.icon});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentTeal, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) Icon(widget.icon, color: accentTeal),
                if (widget.icon != null) const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    widget.message,
                    style: GoogleFonts.poppins(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RatingService {
  final supabase = Supabase.instance.client;

  /// 🔹 MAIN FUNCTION
  Future<void> checkAndShowRatingDialog(BuildContext context) async {
    final pending = await _getPendingRatings();
    if (pending.isEmpty) return;
    await _showRatingDialog(context, pending.first);
  }

  /// 🔹 HELPER: SHOW ANIMATED CARD (Replaces SnackBar)
  void _showAnimatedCard(
    BuildContext context,
    String message, {
    IconData? icon,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 20,
        right: 20,
        child: AnimatedCard(message: message, icon: icon),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  /// 🔹 GET PENDING RATINGS
Future<List<Map<String, dynamic>>> _getPendingRatings() async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  final now = DateTime.now();
  List<Map<String, dynamic>> pending = [];

  try {
    // ✅ STEP 1: Get transactions WITHOUT joins
    final transactions = await supabase
        .from('transactions')
        .select('*')
        .eq('status', 'completed')
        .or('buyer_id.eq.$userId,seller_id.eq.$userId');

    for (var tx in transactions) {
      final completedAt = tx['confirm_at'];
      if (completedAt == null) continue;

      final completedTime = DateTime.parse(completedAt);
      if (now.difference(completedTime).inMinutes < 25) continue;

      // ✅ Check already rated
      final alreadyRated = await supabase
          .from('ratings')
          .select('id')
          .eq('transaction_id', tx['id'])
          .eq('rater_id', userId)
          .limit(1);

      if ((alreadyRated as List).isNotEmpty) continue;

      // ✅ STEP 2: Fetch product name
      final product = await supabase
      .from('products')
    .select('title') // 👈 CHANGE THIS
    .eq('id', tx['product_id'])
    .maybeSingle();
        

      // ✅ STEP 3: Fetch buyer & seller names manually
      final buyerProfile = await supabase
          .from('profiles')
          .select('full_name')
          .eq('user_id', tx['buyer_id'])
          .maybeSingle();

      final sellerProfile = await supabase
          .from('profiles')
          .select('full_name')
          .eq('user_id', tx['seller_id'])
          .maybeSingle();

      tx['product'] = product;
      tx['buyer'] = buyerProfile;
      tx['seller'] = sellerProfile;

      pending.add({'type': 'transaction', 'data': tx});
    }

    // ================= BOOKINGS =================

    final bookings = await supabase
        .from('resource_bookings')
        .select('*')
        .eq('status', 'confirmed')
        .or('user_id.eq.$userId,owner_id.eq.$userId');

    for (var booking in bookings) {
      final date = booking['booking_date'];
      final endTime = booking['end_time'];

      if (date == null || endTime == null) continue;

      final endDateTime = DateTime.parse("$date $endTime");
      if (now.difference(endDateTime).inMinutes < 25) continue;

      final alreadyRated = await supabase
          .from('ratings')
          .select('id')
          .eq('booking_id', booking['id'])
          .eq('rater_id', userId)
          .limit(1);

      if ((alreadyRated as List).isNotEmpty) continue;

      // ✅ Fetch resource
      final resource = await supabase
          .from('resources')
          .select('name')
          .eq('id', booking['resource_id'])
          .maybeSingle();

      // ✅ Fetch user & owner
      final userProfile = await supabase
          .from('profiles')
          .select('full_name')
          .eq('user_id', booking['user_id'])
          .maybeSingle();

      final ownerProfile = await supabase
          .from('profiles')
          .select('full_name')
          .eq('user_id', booking['owner_id'])
          .maybeSingle();

      booking['resource'] = resource;
      booking['user'] = userProfile;
      booking['owner'] = ownerProfile;

      pending.add({'type': 'booking', 'data': booking});
    }
  } catch (e) {
    debugPrint("Error fetching pending ratings: $e");
  }

  return pending;
}

  /// 🔹 SHOW DIALOG
 Future<void> _showRatingDialog(
    BuildContext context, Map<String, dynamic> item) async {
  final userId = supabase.auth.currentUser!.id;
  final data = item['data'];
  final type = item['type'];

  bool isBuyer;
  String ratedUserId;
  String role;
  String name;
  String itemName;

  
  if (type == 'transaction') {
    isBuyer = data['buyer_id'] == userId;
    ratedUserId = isBuyer ? data['seller_id'] : data['buyer_id'];
    role = isBuyer ? 'buyer_to_seller' : 'seller_to_buyer';

    final product = data['product'];
    final buyer = data['buyer'];
    final seller = data['seller'];

    itemName = product?['title'] ?? "Product";

    final buyerName = buyer?['full_name'] ?? "Buyer";
    final sellerName = seller?['full_name'] ?? "Seller";

    name = isBuyer ? sellerName : buyerName;
  // 👉 OPTIONAL: show both names in item line
    itemName = "$itemName\nBuyer: $buyerName | Seller: $sellerName";
    } else {
isBuyer = data['user_id'] == userId;
    ratedUserId = isBuyer ? data['owner_id'] : data['user_id'];
    role = isBuyer ? 'buyer_to_seller' : 'seller_to_buyer';

    final resource = data['resource'];
    final user = data['user'];
    final owner = data['owner'];

    itemName = resource?['name'] ?? "Resource";

    final userName = user?['full_name'] ?? "User";
    final ownerName = owner?['full_name'] ?? "Owner";

    name = isBuyer ? ownerName : userName;
       itemName = "$itemName\nUser: $userName | Owner: $ownerName";
       
    }
    

    int selectedRating = 0;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: accentTeal, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rate_rounded,
                        color: accentTeal,
                        size: 40,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Rate $name",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Item: $itemName", style: GoogleFonts.poppins()),
                      const SizedBox(height: 20),

                      // ⭐ Stars (Wrapped in FittedBox to prevent 4px overflow)
                      FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              onPressed: () {
                                setState(() {
                                  selectedRating = index + 1;
                                });
                              },
                              icon: Icon(
                                Icons.star_rounded,
                                size: 40,
                                color: index < selectedRating
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 🔘 Gradient Submit Button
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: selectedRating == 0 ? null : appGradient,
                          color: selectedRating == 0
                              ? Colors.grey.shade300
                              : null,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ElevatedButton(
                          onPressed: selectedRating == 0
                              ? null
                              : () async {
                                  try {
                                    await supabase.from('ratings').insert({
                                      'rater_id': userId,
                                      'rated_user_id': ratedUserId,
                                      'role': role,
                                      'rating': selectedRating,
                                      if (type == 'transaction')
                                        'transaction_id': data['id'],
                                      if (type == 'booking')
                                        'booking_id': data['id'],
                                    });

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _showAnimatedCard(
                                        context,
                                        "Rating submitted successfully ⭐",
                                        icon: Icons.check_circle_outline,
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      _showAnimatedCard(
                                        context,
                                        "Error submitting rating",
                                        icon: Icons.error_outline,
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            "Submit",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
