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

  const BookingScreen({
    super.key,
    required this.resourceId,
    required this.resourceName,
    required this.ownerId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

// ================== Payment Enum ==================
enum PaymentMethod {
  jazzCash,
  cashOnDelivery,
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  PaymentMethod? _selected;

  final Color _teal = const Color(0xFF008080);
  final double _radius = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light,

      body: Column(
        children: [
          AppBarWidget(
            title: "Reserve",
            onBack: () => Navigator.pop(context),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildChoiceCard(
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_teal, _teal.withOpacity(0.85)],
                          ),
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

                  // ================= PAYMENT (ADDED, SAME STYLE) =================
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _paymentOption(
                    title: 'JazzCash',
                    subtitle: 'Pay securely using JazzCash wallet or app.',
                    imagePath: 'assets/jazzcash.png',
                    value: PaymentMethod.jazzCash,
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
                    child: ElevatedButton(
                      onPressed: _onBookPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_radius),
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

  // ================= BOOK LOGIC =================
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

    final supabase = Supabase.instance.client;

    final start = "${startTime!.hour}:${startTime!.minute}";
    final end = "${endTime!.hour}:${endTime!.minute}";

    try {
      final conflict = await supabase
          .from('resource_bookings')
          .select()
          .eq('resource_id', widget.resourceId)
          .eq('booking_date', selectedDate!.toIso8601String())
          .or('start_time.lt.$end,end_time.gt.$start');

      if ((conflict as List).isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This time slot is already booked')),
        );
        return;
      }

      await supabase.from('resource_bookings').insert({
        'resource_id': widget.resourceId,
          'user_id': supabase.auth.currentUser!.id,
        'owner_id': widget.ownerId,
        'booking_date': selectedDate!.toIso8601String(),
        'start_time': start,
        'end_time': end,
        'payment_method': _selected!.name,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successful')),
      );

      Navigator.pop(context);
    } catch (e) {
      print("BOOKING ERROR: $e");
    }
  }

  // ================= PAYMENT OPTION =================
  Widget _paymentOption({
    required String title,
    required String subtitle,
    required String imagePath,
    required PaymentMethod value,
  }) {
    final selected = _selected == value;

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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 50,
                height: 50,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: value,
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================
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

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
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