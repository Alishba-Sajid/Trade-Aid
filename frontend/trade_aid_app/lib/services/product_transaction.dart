import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/dashboard/dashboard.dart';

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
          .select('*, product_id(title)')
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
          tx['product_id']?['title'] ?? 'Product',
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
      builder: (ctx) => AlertDialog(
        title: const Text("Transaction Confirmation"),
        content: Text(
          isBuyer
              ? "Have you paid for \"$productName\"?"
              : "Have you received payment for \"$productName\"?",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _submitResponse(ctx, tx, isBuyer, true);
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () async {
              await _submitResponse(ctx, tx, isBuyer, false);
            },
            child: const Text("No"),
          ),
        ],
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

        /// ⏱ TIME LOGIC (FIXED CLEAN)
        final bookingDate = DateTime.parse(booking['booking_date']);
        final endTime = booking['end_time'].toString().split(':');

        final endDateTime = DateTime(
          bookingDate.year,
          bookingDate.month,
          bookingDate.day,
          int.parse(endTime[0]),
          int.parse(endTime[1]),
        );

        /// ✅ Trigger AFTER 30 mins
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
      builder: (ctx) => AlertDialog(
        title: const Text("Payment Confirmation"),
        content: Text(
          isBuyer
              ? "Have you paid for $resourceName?"
              : "Have you received payment for $resourceName?",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _submitResponse(ctx, booking, isBuyer, true);
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () async {
              await _submitResponse(ctx, booking, isBuyer, false);
            },
            child: const Text("No"),
          ),
        ],
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

    /// ✅ KEEP YOUR STATUS SYSTEM (IMPORTANT FOR HISTORY)
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