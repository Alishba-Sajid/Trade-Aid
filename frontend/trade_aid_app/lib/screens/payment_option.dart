import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';

/// Screen for selecting payment method before checkout
class PaymentSelectionScreen extends StatefulWidget {
  const PaymentSelectionScreen({super.key});

  @override
  State<PaymentSelectionScreen> createState() =>
      _PaymentSelectionScreenState();
}

/// Supported payment methods
enum PaymentMethod {
  jazzCash,
  easyPaisa,
  cashOnDelivery,
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  /// Currently selected payment method
  PaymentMethod? _selected = PaymentMethod.jazzCash;

  /// Handles "Next" button click
  /// This is backend-ready and can later trigger:
  /// - API call
  /// - Order confirmation
  /// - Payment gateway flow
  void _onNext() {
    if (_selected == null) return;

    // TEMP feedback (replace with API call later)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Selected payment: ${_selected!.name}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );

    /*
      FUTURE BACKEND INTEGRATION EXAMPLE:
      await paymentService.savePaymentMethod(
        orderId: orderId,
        method: _selected!,
      );
    */
  }

  /// Builds a single payment option card
  /// Reusable and scalable for API-driven payment methods
  Widget _paymentOption({
    required String title,
    required String subtitle,
    required String imagePath,
    required PaymentMethod value,
  }) {
    final bool selected = _selected == value;

    return InkWell(
      onTap: () => setState(() => _selected = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.teal : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Payment provider logo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),

            // Title + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Selection radio
            Radio<PaymentMethod>(
              value: value,
              groupValue: _selected,
              activeColor: Colors.teal,
              onChanged: (v) => setState(() => _selected = v),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      /// ✅ Custom reusable AppBar (UI identical across app)
      appBar: AppBarWidget(
        title: 'Payments',
        onBack: () => Navigator.pop(context),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose your payment method',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // JazzCash option
            _paymentOption(
              title: 'JazzCash',
              subtitle: 'Pay securely using JazzCash wallet or app.',
              imagePath: 'assets/jazzcash.png',
              value: PaymentMethod.jazzCash,
            ),

            // EasyPaisa option
            _paymentOption(
              title: 'EasyPaisa',
              subtitle: 'Pay quickly using your EasyPaisa account.',
              imagePath: 'assets/easypaisa.png',
              value: PaymentMethod.easyPaisa,
            ),

            // Cash on Delivery option
            _paymentOption(
              title: 'Cash on Delivery',
              subtitle: 'Pay in cash when your order arrives.',
              imagePath: 'assets/cashondelivery.png',
              value: PaymentMethod.cashOnDelivery,
            ),

            const Spacer(),

            // Next button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
