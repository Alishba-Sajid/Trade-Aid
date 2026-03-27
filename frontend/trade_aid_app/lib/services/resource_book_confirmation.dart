import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResourceTransactionWatcher {
  static void start(BuildContext context) {
    _checkPendingResourcePayments(context);
  }

  static Future<void> _checkPendingResourcePayments(
      BuildContext context) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final now = DateTime.now();

      /// ✅ Fetch bookings WITH resource name (JOIN)
      final bookings = await supabase
          .from('resource_bookings')
          .select('''
            *,
            resources(name)
          ''')
          .or('user_id.eq.${user.id},owner_id.eq.${user.id}')
          .eq('status', 'confirmed'); // ✅ only active bookings

      for (final booking in bookings) {
        /// ✅ Combine date + time properly
        final bookingDate = DateTime.parse(booking['booking_date']);

        final endParts = booking['end_time'].split(':');


        final endDateTime = DateTime(
          bookingDate.year,
          bookingDate.month,
          bookingDate.day,
          int.parse(endParts[0]),
          int.parse(endParts[1]),
        );

        /// ✅ Check if 30 minutes passed after end
        if (now.isAfter(endDateTime.add(const Duration(minutes: 30)))) {
         final isBuyer = booking['user_id'] == user.id;

final alreadyResponded = isBuyer
    ? booking['buyer_confirmed'] == true
    : booking['owner_confirmed'] == true;

if (alreadyResponded) continue;

          _showPaymentDialog(context, booking, user.id);
          break; // only one dialog at a time
        }
      }
    } catch (e) {
      debugPrint("Resource watcher error: $e");
    }
  }

  static void _showPaymentDialog(
      BuildContext context, Map booking, String userId) {
    final supabase = Supabase.instance.client;

    final isBuyer = booking['user_id'] == userId;

    /// ✅ Get resource name from JOIN
    final resourceName = booking['resources']?['name'] ?? 'Resource';

    final start = booking['start_time'];
    final end = booking['end_time'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Payment Confirmation"),
        content: Text(
          isBuyer
              ? "Have you paid for $resourceName from $start to $end?"
              : "Have you received payment for $resourceName from $start to $end?",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              /// ✅ YES
              if (isBuyer) {
                await supabase.from('resource_bookings').update({
                  'buyer_confirmed': true,
                }).eq('id', booking['id']);
              } else {
                await supabase.from('resource_bookings').update({
                  'owner_confirmed': true,
                }).eq('id', booking['id']);
              }

              await _resolveBooking(booking['id']);

              Navigator.pop(context);
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () async {
              /// ❌ DISPUTE
              if (isBuyer) {
  await supabase.from('resource_bookings').update({
    'buyer_confirmed': false,
  }).eq('id', booking['id']);
} else {
  await supabase.from('resource_bookings').update({
    'owner_confirmed': false,
  }).eq('id', booking['id']);
}

await _resolveBooking(booking['id']);

              Navigator.pop(context);
            },
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

static Future<void> _resolveBooking(String bookingId) async {
  final supabase = Supabase.instance.client;

  final booking = await supabase
      .from('resource_bookings')
      .select()
      .eq('id', bookingId)
      .maybeSingle();

  if (booking == null) return;

  final buyerConfirmed = booking['buyer_confirmed'] == true;
  final ownerConfirmed = booking['owner_confirmed'] == true;

  /// ✅ CASE 1: BOTH YES → COMPLETE
  if (buyerConfirmed && ownerConfirmed) {
    await supabase.from('resource_bookings').update({
      'status': 'completed_final'
    }).eq('id', bookingId);
  }

  /// ❌ CASE 2: ANYONE SAID NO → DISPUTED
  else if (
    (buyerConfirmed && !ownerConfirmed) ||
    (!buyerConfirmed && ownerConfirmed) ||
    (!buyerConfirmed && !ownerConfirmed)
  ) {
    await supabase.from('resource_bookings').update({
      'status': 'disputed'
    }).eq('id', bookingId);
  }
}
}