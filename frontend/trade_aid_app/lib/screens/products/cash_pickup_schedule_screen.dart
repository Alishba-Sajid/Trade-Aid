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

// ✅ Animated card widget (same style as login/create account)
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 17, 158, 144),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null)
                  Icon(
                    widget.icon,
                    color: const Color.fromARGB(255, 17, 158, 144),
                  ),
                if (widget.icon != null) const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.black),
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

class CashPickupScheduleScreen extends StatefulWidget {
  final String productId;

  const CashPickupScheduleScreen({super.key, required this.productId});

  @override
  State<CashPickupScheduleScreen> createState() =>
      _CashPickupScheduleScreenState();
}

class _CashPickupScheduleScreenState extends State<CashPickupScheduleScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3)),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: accentTeal)),
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

  // Helper method for the animated card
  void _showAnimatedCard(String message, {IconData? icon}) {
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
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  Future<void> _confirmSchedule() async {
    if (selectedDate == null || selectedTime == null) return;

    setState(() => isLoading = true);
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final today = DateTime.now();
    final maxDate = today.add(const Duration(days: 3));

    if (selectedDate!.isAfter(maxDate)) {
      setState(() => isLoading = false);
      _showAnimatedCard(
        'You must schedule within the next 3 days',
        icon: Icons.warning,
      );
      return;
    }

    try {
      final product = await supabase
          .from('products')
          .select('user_id, status')
          .eq('id', widget.productId)
          .single();

      final sellerId = product['user_id'];

      if (product['status'] != 'available') {
        setState(() => isLoading = false);
        _showAnimatedCard("Product already reserved", icon: Icons.error);
        return;
      }

      final scheduledDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      // ✅ STEP 1: Reserve product
      final updateResponse = await supabase
          .from('products')
          .update({'status': 'reserved', 'reserved_for': user.id})
          .eq('id', widget.productId)
          .eq('status', 'available')
          .select();

      if (updateResponse.isEmpty) {
        setState(() => isLoading = false);
        _showAnimatedCard("Product already reserved", icon: Icons.error);
        return;
      }

      // ✅ STEP 2: Create transaction
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

      // 🔔 NOTIFICATIONS
      final buyerProfile = await supabase
          .from('profiles')
          .select('full_name')
          .eq('user_id', user.id)
          .single();

      final productDetails = await supabase
          .from('products')
          .select('title')
          .eq('id', widget.productId)
          .single();

      final formattedTime = selectedTime!.format(context);

      await NotificationService.createNotification(
        userId: sellerId,
        title: "New Reservation",
        message:
            "${buyerProfile['full_name']} has reserved your product '${productDetails['title']}' at $formattedTime",
        type: "product_booking",
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      _showAnimatedCard("Pickup Scheduled Successfully 🎉", icon: Icons.check);
    } on PostgrestException catch (e) {
      setState(() => isLoading = false);
      _showAnimatedCard(e.message, icon: Icons.error);
    }
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
            _buildSectionHeader(
              "Pick a Date",
              "When should we collect the cash?",
            ),
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
            _buildSectionHeader(
              "Select Time Slot",
              "Choose a convenient window.",
            ),
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
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed:
                    (selectedDate != null && selectedTime != null && !isLoading)
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
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
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
        Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
              blurRadius: isSelected ? 20 : 15,
              offset: isSelected ? const Offset(0, 10) : const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white.withOpacity(0.5), width: 1)
                    : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: 26,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : dark,
                    ),
                    child: Text(title),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withOpacity(0.85)
                          : Colors.grey.shade500,
                    ),
                    child: Text(subtitle),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.white : subtleGrey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: accentTeal)
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
