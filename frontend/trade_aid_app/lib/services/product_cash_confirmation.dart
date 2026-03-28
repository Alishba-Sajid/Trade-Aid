import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductTransactionService {
  static Future<void> checkPendingTransactions(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('transactions')
        .select(
          'id, product_id, buyer_id, seller_id, buyer_confirmed, seller_confirmed, product_id(title)',
        )
        .or('buyer_id.eq.${user.id},seller_id.eq.${user.id}')
        .eq('status', 'pending');

    for (final tx in data) {
      final isBuyer = tx['buyer_id'] == user.id;
      final buyerConfirmed = tx['buyer_confirmed'];
      final sellerConfirmed = tx['seller_confirmed'];

      // Show dialog only if the current user has not responded yet
      if (isBuyer && buyerConfirmed != null) continue;
      if (!isBuyer && sellerConfirmed != null) continue;

      final productName = tx['product_id']?['title'] ?? 'Product';

      Future.delayed(Duration.zero, () {
        _showConfirmationDialog(context, tx, isBuyer, productName);
      });

      break;
    }
  }

  static Future<void> _resolveTransaction(Map transaction) async {
    final supabase = Supabase.instance.client;

    final tx = await supabase
        .from('transactions')
        .select()
        .eq('id', transaction['id'])
        .maybeSingle();

    if (tx == null) return;

    final buyerConfirmed = tx['buyer_confirmed'];
    final sellerConfirmed = tx['seller_confirmed'];

    // ✅ Declare FIRST
    String productStatus;
    String txStatus;

    // ✅ Logic
    if (buyerConfirmed == true && sellerConfirmed == true) {
      txStatus = 'completed';
      productStatus = 'sold';
    } else if ((buyerConfirmed == true && sellerConfirmed == false) ||
        (buyerConfirmed == false && sellerConfirmed == true)) {
      txStatus = 'disputed';
      productStatus = 'disputed';
    } else if (buyerConfirmed == false && sellerConfirmed == false) {
      txStatus = 'cancelled';
      productStatus = 'available';
    } else {
      // ⏳ wait for both responses
      return;
    }

    // ✅ Update transaction
    await supabase
        .from('transactions')
        .update({'status': txStatus})
        .eq('id', tx['id']);

    // ✅ Update product (WITH RESET LOGIC)
    if (productStatus == 'available') {
      await supabase
          .from('products')
          .update({'status': 'available', 'reserved_for': null})
          .eq('id', tx['product_id']);
    } else {
      await supabase
          .from('products')
          .update({
            'status': productStatus,
            'reserved_for': tx['buyer_id'], // 🔥 KEEP IT LOCKED
          })
          .eq('id', tx['product_id']);
    }
  }

  /// Show dialog for the current user
  static void _showConfirmationDialog(
    BuildContext context,
    Map transaction,
    bool isBuyer,
    String productName,
  ) {
    final supabase = Supabase.instance.client;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Transaction Confirmation"),
        content: Text(
          isBuyer
              ? "Have you paid for \"$productName\"?"
              : "Have you received payment for \"$productName\"?",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // YES selected
              if (isBuyer) {
                await supabase
                    .from('transactions')
                    .update({'buyer_confirmed': true})
                    .eq('id', transaction['id']);
              } else {
                await supabase
                    .from('transactions')
                    .update({'seller_confirmed': true})
                    .eq('id', transaction['id']);
              }

              await _resolveTransaction(transaction);
              Navigator.pop(context);
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () async {
              // NO selected
              if (isBuyer) {
                await supabase
                    .from('transactions')
                    .update({'buyer_confirmed': false})
                    .eq('id', transaction['id']);
              } else {
                await supabase
                    .from('transactions')
                    .update({'seller_confirmed': false})
                    .eq('id', transaction['id']);
              }

              await _resolveTransaction(transaction);
              Navigator.pop(context);
            },
            child: const Text("No"),
          ),
        ],
      ),
    );
  }
}
