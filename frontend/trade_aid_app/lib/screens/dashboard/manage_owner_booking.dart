import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// COLORS
const Color darkPrimary = Color(0xFF004D40);
const Color accentTeal = Color(0xFF119E90);
const Color backgroundLight = Color(0xFFF0F9F8);

const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF2E9499), Color(0xFF119E90)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ManageOwnerBookingsScreen extends StatefulWidget {
  const ManageOwnerBookingsScreen({super.key});

  @override
  State<ManageOwnerBookingsScreen> createState() =>
      _ManageOwnerBookingsScreenState();
}

class _ManageOwnerBookingsScreenState extends State<ManageOwnerBookingsScreen> {
  final supabase = Supabase.instance.client;
  final Color primaryTeal = const Color(0xFF119E90);

  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  // 🔥 ANIMATED CARD NOTIFICATION (BOTTOM DISPLAY)
  void _showAnimatedCard(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedNotification(
        message: message,
        isError: isError,
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }

  // 🔥 FETCH BOOKINGS (Logic Preserved)
  Future<void> _fetchBookings() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await supabase
          .from('resource_bookings')
          .select('''
            *,
            resources(name, images),
            profiles!resource_bookings_user_fk(full_name)
          ''')
          .eq('owner_id', user.id)
          .order('booking_date', ascending: true);

      final now = DateTime.now();

      final filtered = (response as List).where((item) {
        try {
          final bookingDate = DateTime.parse(item['booking_date']);
          final endParts = item['end_time'].toString().split(':');

          final endTime = DateTime(
            bookingDate.year,
            bookingDate.month,
            bookingDate.day,
            int.parse(endParts[0]),
            int.parse(endParts[1]),
          );

          return endTime.isAfter(now);
        } catch (_) {
          return false;
        }
      }).toList();

      if (!mounted) return;

      setState(() {
        bookings = List<Map<String, dynamic>>.from(filtered);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showAnimatedCard("Load failed: $e", isError: true);
    }
  }

  // 🔥 PENALTY CHECK
  bool isPenaltyApplicable(Map booking) {
    try {
      final bookingDate = DateTime.parse(booking['booking_date']);
      final startParts = booking['start_time'].toString().split(':');

      final bookingStart = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      final cutoff = bookingStart.subtract(const Duration(hours: 3));
      return DateTime.now().isAfter(cutoff);
    } catch (_) {
      return false;
    }
  }

  // 🔥 DELETE BOOKING
  Future<void> _deleteBooking(Map booking) async {
    final penalty = isPenaltyApplicable(booking);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: penalty
                ? LinearGradient(colors: [Colors.red.shade700, Colors.red.shade400])
                : appGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: penalty
                        ? LinearGradient(colors: [Colors.red.shade700, Colors.red.shade400])
                        : appGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    penalty ? Icons.warning_amber_rounded : Icons.calendar_today,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Cancel Booking?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: penalty ? Colors.red.shade700 : const Color(0xFF0F777C),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  penalty
                      ? "⚠️ Cancelling now will reduce your rating by 2.\n\nDo you want to continue?"
                      : "Are you sure you want to cancel this booking?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("No", style: TextStyle(color: Colors.grey[600])),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: penalty ? Colors.red : accentTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white)),
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

    if (confirm != true) return;

    try {
      final id = booking['id'];
      final response = await supabase
          .from('resource_bookings')
          .delete()
          .eq('id', id)
          .select();

      if (response.isEmpty) {
        if (!mounted) return;
        _showAnimatedCard("Delete failed (Permissions/RLS)", isError: true);
        return;
      }

      if (!mounted) return;
      setState(() {
        bookings.removeWhere((b) => b['id'] == id);
      });

      _showAnimatedCard(penalty ? "Deleted with penalty." : "Deleted successfully");
    } catch (e) {
      if (!mounted) return;
      _showAnimatedCard("Error: $e", isError: true);
    }
  }

  // 🔥 TIME FORMATTER
  String formatTime(String time24) {
    final parts = time24.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    final period = hour >= 12 ? "PM" : "AM";
    hour = hour % 12 == 0 ? 12 : hour % 12;
    return "$hour:${minute.toString().padLeft(2, '0')} $period";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Manage Bookings",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appGradient),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryTeal))
          : bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text("No bookings found",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final item = bookings[index];
                    final resource = item['resources'];
                    final user = item['profiles'];
                    final imageUrl = (resource['images'] as List?)?.isNotEmpty == true
                        ? resource['images'][0]
                        : null;
                    final penalty = isPenaltyApplicable(item);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      width: 85,
                                      height: 85,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 85,
                                      height: 85,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.image, color: Colors.grey[400]),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    resource['name'] ?? 'Resource',
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  _infoRow(Icons.person_outline, user?['full_name'] ?? 'User'),
                                  const SizedBox(height: 4),
                                  _infoRow(Icons.calendar_month_outlined, item['booking_date']),
                                  const SizedBox(height: 4),
                                  _infoRow(Icons.access_time, 
                                    "${formatTime(item['start_time'])} - ${formatTime(item['end_time'])}"),
                                  if (penalty) _penaltyBadge(),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteBooking(item),
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: primaryTeal),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }

  Widget _penaltyBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
          const SizedBox(width: 4),
          Text(
            "Penalty Applies",
            style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// 🔥 CUSTOM ANIMATED CARD WIDGET (REPOSITIONED TO BOTTOM)
class _AnimatedNotification extends StatefulWidget {
  final String message;
  final bool isError;
  const _AnimatedNotification({required this.message, required this.isError});

  @override
  State<_AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Starts from below the screen and slides up to the bottom position
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
    
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter, // Displays at bottom
        child: SlideTransition(
          position: _offsetAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40), // Spacing from bottom edge
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isError ? Colors.red : const Color(0xFF119E90),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -4), // Shadow directed upwards
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isError ? Icons.error_outline : Icons.check_circle_outline,
                      color: widget.isError ? Colors.red : const Color(0xFF119E90),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Color(0xFF004D40),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}