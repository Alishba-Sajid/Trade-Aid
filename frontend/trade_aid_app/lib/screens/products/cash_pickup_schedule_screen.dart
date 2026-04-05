import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/time_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_aid_app/services/notification_service.dart';

// 🌿 Premium Fintech Palette
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF0F777C), Color(0xFF119E90)],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color dark = Color(0xFF0B2F2A);
const Color accentTeal = Color(0xFF119E90);
const Color surface = Color(0xFFFFFFFF);
const Color backgroundLight = Color(0xFFF6F7F7);
const Color subtleGrey = Color(0xFFE3E6E6);

class CashPickupScheduleScreen extends StatefulWidget {
  final String productId;

  const CashPickupScheduleScreen({
    super.key,
    required this.productId,
  });

  @override
  State<CashPickupScheduleScreen> createState() =>
      _CashPickupScheduleScreenState();
}

class _CashPickupScheduleScreenState extends State<CashPickupScheduleScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final supabase = Supabase.instance.client;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: accentTeal),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTealTimePicker(
      context,
      initialTime: TimeOfDay.now(),
      primary: accentTeal,
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _confirmSchedule() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final today = DateTime.now();
    final maxDate = today.add(const Duration(days: 3));

    if (selectedDate!.isAfter(maxDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must schedule within the next 3 days')),
      );
      return;
    }

    final product = await supabase
        .from('products')
        .select('user_id, status')
        .eq('id', widget.productId)
        .single();

    final sellerId = product['user_id'];

    // 🚨 BLOCK if already reserved
    if (product['status'] != 'available') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product already reserved")),
      );
      return;
    }

    // 🔍 CHECK existing pending transaction FIRST
    final existing = await supabase
        .from('transactions')
        .select()
        .eq('product_id', widget.productId)
        .eq('status', 'pending');

    if (existing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product already reserved")),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    // ✅ STEP 1: Reserve product FIRST
    final updateResponse = await supabase
        .from('products')
        .update({
          'status': 'reserved',
          'reserved_for': user.id,
        })
        .eq('id', widget.productId)
        .eq('status', 'available')
        .select();

    if (updateResponse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product already reserved")),
      );
      return;
    }

    // ✅ STEP 2: THEN create transaction
    try {
      await supabase.from('transactions').insert({
        'product_id': widget.productId,
        'buyer_id': user.id,
        'seller_id': sellerId,
        'scheduled_at': scheduledDateTime.toIso8601String(),
        'confirm_at': scheduledDateTime
            .add(const Duration(minutes: 30))
            .toIso8601String(),
        'auto_resolve_at': scheduledDateTime
            .add(const Duration(hours: 48))
            .toIso8601String(),
      });
    } catch (e) {
      // rollback if insert fails
      await supabase.from('products').update({
        'status': 'available',
        'reserved_for': null,
      }).eq('id', widget.productId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction failed: $e")),
      );
      return;
    }
    // 🔔 FETCH buyer name + product name
final buyerProfile = await supabase
    .from('profiles')
    .select('full_name')
    .eq('user_id', user.id)
    .single();

final productDetails = await supabase
    .from('products')
    .select('name')
    .eq('id', widget.productId)
    .single();

// ⏰ FORMAT TIME (12-hour)
final formattedTime =
    TimeOfDay.fromDateTime(scheduledDateTime).format(context);

// 🔔 SEND NOTIFICATION TO SELLER
await NotificationService.createNotification(
  userId: sellerId,
  title: "New Booking",
  message:
      "${buyerProfile['full_name']} has booked your product '${productDetails['name']}' at $formattedTime",
  type: "product_booking",
);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pickup Scheduled Successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBarWidget(
        title: "Cash Payment Schedule",
        onBack: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SCHEDULE DETAILS",
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                color: Colors.grey,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader("Pick a Date", "When should we collect the cash?"),
            const SizedBox(height: 12),
            _premiumGradientCard(
              icon: Icons.calendar_month_rounded,
              title: "Pickup Date",
              subtitle: selectedDate == null
                  ? "Assign collection date"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              isSelected: selectedDate != null,
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Select Time Slot", "Choose a convenient window."),
            const SizedBox(height: 12),
            _premiumGradientCard(
              icon: Icons.history_toggle_off_rounded,
              title: "Pickup Time",
              subtitle: selectedTime == null
                  ? "Assign collection time"
                  : selectedTime!.format(context),
              isSelected: selectedTime != null,
              onTap: _pickTime,
            ),
            const SizedBox(height: 32),
            _buildTermsAndConditions(),
            const Spacer(),
            Container(
              height: 58,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accentTeal.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: (selectedDate != null && selectedTime != null)
                    ? _confirmSchedule
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentTeal,
                  disabledBackgroundColor: accentTeal.withOpacity(0.4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Confirm Schedule",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

  Widget _buildSectionHeader(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: dark,
          ),
        ),
        Text(
          desc,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _premiumGradientCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? appGradient : null,
          color: isSelected ? null : surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accentTeal.withOpacity(0.25)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? accentTeal : Colors.grey.shade400,
                size: 26,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withOpacity(0.85)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : subtleGrey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 12,
                        width: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    final terms = [
      "Once you reserve a product, you can not modify the time. If you need to change, please cancel and rebook.",
      "In case of not showing up without canceling effects your reliability score.",
      "Make sure bring the amount in cash",
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms & Conditions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: dark,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              terms.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < terms.length - 1 ? 12 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: accentTeal.withOpacity(0.85),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        terms[index],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}