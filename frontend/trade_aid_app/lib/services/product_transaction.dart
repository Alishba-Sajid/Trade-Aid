import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/dashboard/dashboard.dart';

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

/// ================= PRODUCT =================

class ProductTransactionService {
  static Future<void> checkPendingTransactions(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null || GlobalDialogManager.isDialogOpen) return;

    try {
      final now = DateTime.now().toIso8601String();

      final data = await supabase
          .from('transactions')
          .select('*, products(title)')
          .or('buyer_id.eq.${user.id},seller_id.eq.${user.id}')
          .eq('status', 'pending')
          .lte('confirm_at', now);

      for (final tx in data) {
        final isBuyer = tx['buyer_id'].toString() == user.id;

        final String uniqueKey = "product_${tx['id']}_${user.id}";

        if (GlobalDialogManager.shownIds.contains(uniqueKey)) continue;

        final hasResponded = isBuyer
            ? tx['buyer_confirmed'] != null
            : tx['seller_confirmed'] != null;

        if (hasResponded) continue;

        GlobalDialogManager.isDialogOpen = true;
        GlobalDialogManager.shownIds.add(uniqueKey);

        _showConfirmationDialog(
          context,
          tx,
          isBuyer,
          tx['products']?['title'] ?? 'Product',
        );

        break;
      }
    } catch (e) {
      debugPrint("Transaction watcher error: $e");
    }
  }

  static void _showConfirmationDialog(
      BuildContext context, Map tx, bool isBuyer, String productName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: accentTeal, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Transaction Confirmation",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  isBuyer
                      ? "Have you paid for \"$productName\"?"
                      : "Have you received payment for \"$productName\"?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async => await _submitResponse(ctx, tx, isBuyer, false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("No", style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: appGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () async => await _submitResponse(ctx, tx, isBuyer, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Yes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  }

  static Future<void> _submitResponse(
      BuildContext ctx, Map tx, bool isBuyer, bool confirmed) async {
    final supabase = Supabase.instance.client;

    await supabase.from('transactions').update({
      isBuyer ? 'buyer_confirmed' : 'seller_confirmed': confirmed
    }).eq('id', tx['id']);

    await _resolveTransaction(tx);

    Navigator.pop(ctx);

    await Future.delayed(const Duration(seconds: 1));
    GlobalDialogManager.isDialogOpen = false;
  }

  static Future<void> _resolveTransaction(Map transaction) async {
    final supabase = Supabase.instance.client;

    final tx = await supabase
        .from('transactions')
        .select()
        .eq('id', transaction['id'])
        .maybeSingle();

    if (tx == null) return;

    final bConf = tx['buyer_confirmed'];
    final sConf = tx['seller_confirmed'];

    if (bConf == null || sConf == null) return;

    String txStatus;
    String prodStatus;

    if (bConf == true && sConf == true) {
      txStatus = 'completed';
      prodStatus = 'sold';
    } else if (bConf == false && sConf == false) {
      txStatus = 'cancelled';
      prodStatus = 'available';
    } else {
      txStatus = 'disputed';
      prodStatus = 'disputed';
    }

    await supabase
        .from('transactions')
        .update({'status': txStatus})
        .eq('id', tx['id']);

    await supabase.from('products').update({
      'status': prodStatus,
      'reserved_for': prodStatus == 'available' ? null : tx['buyer_id'],
    }).eq('id', tx['product_id']);
  }
}

/// ================= RESOURCE =================

class ResourceTransactionWatcher {
  static Future<void> start(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null || GlobalDialogManager.isDialogOpen) return;

    try {
      final now = DateTime.now();

      final bookings = await supabase
          .from('resource_bookings')
          .select('*, resources(name)')
          .or('user_id.eq.${user.id},owner_id.eq.${user.id}')
          .inFilter('status', ['confirmed']);

      for (final booking in bookings) {
        final isBuyer = booking['user_id'].toString() == user.id;

        final String uniqueKey = "resource_${booking['id']}_${user.id}";

        if (GlobalDialogManager.shownIds.contains(uniqueKey)) continue;

        final hasResponded = isBuyer
            ? booking['buyer_confirmed'] != null
            : booking['owner_confirmed'] != null;

        if (hasResponded) continue;

        final bookingDate = DateTime.parse(booking['booking_date']);
        final endTime = booking['end_time'].toString().split(':');

        final endDateTime = DateTime(
          bookingDate.year,
          bookingDate.month,
          bookingDate.day,
          int.parse(endTime[0]),
          int.parse(endTime[1]),
        );

        if (now.isAfter(endDateTime.add(const Duration(minutes: 30)))) {
          GlobalDialogManager.isDialogOpen = true;
          GlobalDialogManager.shownIds.add(uniqueKey);

          _showPaymentDialog(context, booking, isBuyer);
          break;
        }
      }
    } catch (e) {
      debugPrint("Resource watcher error: $e");
    }
  }

  static void _showPaymentDialog(
      BuildContext context, Map booking, bool isBuyer) {
    final resourceName = booking['resources']?['name'] ?? 'Resource';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.payments_outlined, color: accentTeal, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Payment Confirmation",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  isBuyer
                      ? "Have you paid for $resourceName?"
                      : "Have you received payment for $resourceName?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async => await _submitResponse(ctx, booking, isBuyer, false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("No", style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: appGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () async => await _submitResponse(ctx, booking, isBuyer, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Yes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  }

  static Future<void> _submitResponse(
      BuildContext ctx, Map booking, bool isBuyer, bool confirmed) async {
    final supabase = Supabase.instance.client;

    await supabase.from('resource_bookings').update({
      isBuyer ? 'buyer_confirmed' : 'owner_confirmed': confirmed
    }).eq('id', booking['id']);

    await _resolveBooking(booking['id']);

    Navigator.pop(ctx);

    await Future.delayed(const Duration(seconds: 1));
    GlobalDialogManager.isDialogOpen = false;
  }

  static Future<void> _resolveBooking(String bookingId) async {
    final supabase = Supabase.instance.client;

    final booking = await supabase
        .from('resource_bookings')
        .select()
        .eq('id', bookingId)
        .maybeSingle();

    if (booking == null) return;

    final bConf = booking['buyer_confirmed'];
    final oConf = booking['owner_confirmed'];

    if (bConf == null || oConf == null) return;

    String status;

    if (bConf == true && oConf == true) {
      status = 'completed_final';
    } else if (bConf == false && oConf == false) {
      status = 'disputed';
    } else {
      status = 'disputed';
    }

    await supabase
        .from('resource_bookings')
        .update({'status': status})
        .eq('id', bookingId);
  }
}