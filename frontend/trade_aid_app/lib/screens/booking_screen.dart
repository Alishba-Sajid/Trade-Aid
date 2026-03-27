import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/time_picker.dart';
import '../widgets/app_bar.dart';

const Color light = Color(0xFFF0F9F8);

// ================== Booking Screen ==================
class BookingScreen extends StatefulWidget {
  final String resourceId;
  final String resourceName;
  final String ownerId;
  final String startTimeLimit;
  final String endTimeLimit;

  const BookingScreen({
    super.key,
    required this.resourceId,
    required this.resourceName,
    required this.ownerId,
    required this.startTimeLimit,
    required this.endTimeLimit,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

// ================== Payment Enum ==================
enum PaymentMethod { jazzCash, cashOnDelivery }

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  PaymentMethod? _selected = PaymentMethod.cashOnDelivery;

  final Color _teal = const Color(0xFF008080);
  final double _radius = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), // Matched to ref background
      body: Column(
        children: [
          AppBarWidget(title: "Reserve", onBack: () => Navigator.pop(context)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resource Name
                  Text(
                    widget.resourceName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ================= DATE =================
                  const Text(
                    'Select Date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildChoiceCard(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _teal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        selectedDate == null
                            ? 'Choose Date'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: TextButton(
                        onPressed: _pickDate,
                        child: Text(
                          'Pick',
                          style: TextStyle(
                            color: _teal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ================= TIME =================
                  const Text(
                    'Select Time (Start & End)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceCard(
                          child: TextButton(
                            onPressed: _pickStartTime,
                            child: Text(
                              startTime == null
                                  ? 'Start Time'
                                  : startTime!.format(context),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _teal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildChoiceCard(
                          child: TextButton(
                            onPressed: _pickEndTime,
                            child: Text(
                              endTime == null
                                  ? 'End Time'
                                  : endTime!.format(context),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _teal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ================= PAYMENT =================
                  const Text(
                    'Choose your payment method',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _paymentOption(
                    title: 'JazzCash',
                    subtitle: 'Coming Soon',
                    imagePath: 'assets/jazzcash.png',
                    value: PaymentMethod.jazzCash,
                    enabled: false,
                  ),

                  _paymentOption(
                    title: 'Cash Payment',
                    subtitle: 'Pay in cash.',
                    imagePath: 'assets/cashondelivery.png',
                    value: PaymentMethod.cashOnDelivery,
                  ),

                  const Spacer(),

                  // ================= BOOK BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _onBookPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book',
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
          ),
        ],
      ),
    );
  }

  // ================= PAYMENT OPTION (Refactored to match 1st code) =================
  Widget _paymentOption({
    required String title,
    required String subtitle,
    required String imagePath,
    required PaymentMethod value,
    bool enabled = true,
  }) {
    final bool selected = _selected == value;
    final bool disabled = !enabled;

    return InkWell(
      onTap: disabled ? null : () => setState(() => _selected = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: disabled
                ? Colors.grey.shade400
                : (selected ? _teal : Colors.grey.shade300),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
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

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: disabled ? Colors.black54 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: disabled ? Colors.black45 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Selection Logic (Radio or Lock)
            if (disabled)
              Icon(Icons.lock_outline, size: 20, color: Colors.grey.shade400)
            else
              Radio<PaymentMethod>(
                value: value,
                groupValue: _selected,
                activeColor: _teal,
                onChanged: (v) => setState(() => _selected = v),
              ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS & LOGIC (Kept from 2nd code) =================
  Widget _buildChoiceCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

bool isWithinAllowedTime() {
  int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  final startLimitParts = widget.startTimeLimit.split(":");
  final endLimitParts = widget.endTimeLimit.split(":");

  final startLimitMinutes =
      int.parse(startLimitParts[0]) * 60 + int.parse(startLimitParts[1]);

  final endLimitMinutes =
      int.parse(endLimitParts[0]) * 60 + int.parse(endLimitParts[1]);

  final selectedStart = toMinutes(startTime!);
  final selectedEnd = toMinutes(endTime!);

  // ✅ Ensure selected times are within the allowed window
  if (selectedStart < startLimitMinutes || selectedEnd > endLimitMinutes) {
    return false;
  }

  // ✅ Ensure start is before end
  return selectedStart < selectedEnd;
}
Future<void> _onBookPressed() async {
  if (selectedDate == null ||
      startTime == null ||
      endTime == null ||
      _selected == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please complete all fields')),
    );
    return;
  }

  final today = DateTime.now();
  final maxDate = today.add(const Duration(days: 7));

  if (selectedDate!.isAfter(maxDate)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You must book within the next 7 days')),
    );
    return;
  }

 

  final supabase = Supabase.instance.client;

  String formatTime(TimeOfDay t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00";
  }

  final start = formatTime(startTime!);
  final end = formatTime(endTime!);

  try {
    final conflict = await supabase
        .from('resource_bookings')
        .select()
        .eq('resource_id', widget.resourceId)
        .eq('booking_date', selectedDate!.toIso8601String().split('T')[0])
        .filter('start_time', 'lt', end)
        .filter('end_time', 'gt', start)
        .eq('status', 'confirmed');

    if ((conflict as List).isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Time slot already booked")),
      );
      return;
    }

    await supabase.from('resource_bookings').insert({
      'resource_id': widget.resourceId,
      'user_id': supabase.auth.currentUser!.id,
      'owner_id': widget.ownerId,
      'booking_date': selectedDate!.toIso8601String().split('T')[0],
      'start_time': start,
      'end_time': end,
      'payment_method': _selected!.name,
      'status': 'confirmed',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking successful')),
    );
    Navigator.pop(context);
  } catch (e) {
    debugPrint("BOOKING ERROR: $e");
  }
}

// ✅ NOW PLACE THEM HERE (OUTSIDE)

Future<void> _pickDate() async {
  final today = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? today,
    firstDate: today,
    lastDate: today.add(const Duration(days: 7)),
  );
  if (picked != null) setState(() => selectedDate = picked);
}

Future<void> _pickStartTime() async {
  final picked = await showTealTimePicker(
    context,
    initialTime: startTime ?? TimeOfDay.now(),
    primary: _teal,
  );
  if (picked != null) setState(() => startTime = picked);
}

Future<void> _pickEndTime() async {
  final picked = await showTealTimePicker(
    context,
    initialTime: endTime ?? startTime ?? TimeOfDay.now(),
    primary: _teal,
  );
  if (picked != null) setState(() => endTime = picked);
}
}
