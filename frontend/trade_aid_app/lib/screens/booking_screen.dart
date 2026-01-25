import 'package:flutter/material.dart';
import 'payment_option.dart';
import '../widgets/time_picker.dart';
import '../widgets/app_bar.dart'; // <-- Import the reusable AppBar


const Color light = Color(0xFFF0F9F8);

// ================== Booking Model ==================
class Booking {
  final String resourceId;
  final DateTime date;
  final TimeOfDay start;
  final TimeOfDay end;

  Booking({
    required this.resourceId,
    required this.date,
    required this.start,
    required this.end,
  });
}

// ================== Booking Storage ==================
final List<Booking> _bookings = [];

// Check if two dates are the same day
bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// Convert TimeOfDay to minutes for easier comparison
int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

// Check if a time slot is available
bool isSlotAvailable(
  String resourceId,
  DateTime date,
  TimeOfDay start,
  TimeOfDay end,
) {
  final newStart = _toMinutes(start);
  final newEnd = _toMinutes(end);

  for (final b in _bookings) {
    if (b.resourceId == resourceId && _isSameDay(b.date, date)) {
      final existingStart = _toMinutes(b.start);
      final existingEnd = _toMinutes(b.end);

      // Check for overlapping time slots
      if (newStart < existingEnd && newEnd > existingStart) {
        return false;
      }
    }
  }
  return true;
}

// Add a new booking
void addBooking(Booking booking) {
  _bookings.add(booking);
}

// ================== Booking Screen ==================
class BookingScreen extends StatefulWidget {
  final String resourceId;
  final String resourceName;

  const BookingScreen({
    super.key,
    required this.resourceId,
    required this.resourceName,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  // UI Constants
  final Color _teal = const Color(0xFF008080);
  final double _radius = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light,

      // ================== Body ==================
      body: Column(
        children: [
          // ------------------ Reusable App Bar ------------------
          AppBarWidget(
            title: "Reserve",
            onBack: () => Navigator.pop(context),
          ),

          // ------------------ Booking Form ------------------
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

                  // Date Selection
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
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

                  // Time Selection
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

                  const Spacer(),

                  // Book Button
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

  // ================== Helper Widgets ==================

  /// Generic card for choices (date/time)
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

  // ================== Pickers ==================

  /// Show date picker
  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: _teal,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: Colors.white,
            todayBorder: BorderSide(color: _teal, width: 1.5),
            todayForegroundColor: MaterialStateProperty.all(_teal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  /// Show start time picker
  Future<void> _pickStartTime() async {
    final picked = await showTealTimePicker(
      context,
      initialTime: startTime ?? TimeOfDay.now(),
      primary: _teal,
    );
    if (picked != null) setState(() => startTime = picked);
  }

  /// Show end time picker
  Future<void> _pickEndTime() async {
    final picked = await showTealTimePicker(
      context,
      initialTime: endTime ?? startTime ?? TimeOfDay.now(),
      primary: _teal,
    );
    if (picked != null) setState(() => endTime = picked);
  }

  // ================== Booking Action ==================
  void _onBookPressed() {
    if (selectedDate == null || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose date and time')),
      );
      return;
    }

    if (!isSlotAvailable(widget.resourceId, selectedDate!, startTime!, endTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already booked')),
      );
      return;
    }

    // Add booking
    addBooking(
      Booking(
        resourceId: widget.resourceId,
        date: selectedDate!,
        start: startTime!,
        end: endTime!,
      ),
    );

    // Navigate to payment
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentSelectionScreen()),
    );
  }
}
