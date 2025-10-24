import 'package:flutter/material.dart';
import 'payment_option.dart'; 
import '../widgets/time_picker.dart';
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

final List<Booking> _bookings = [];

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

bool isSlotAvailable(
    String resourceId, DateTime date, TimeOfDay start, TimeOfDay end) {
  final newStart = _toMinutes(start);
  final newEnd = _toMinutes(end);
  for (final b in _bookings) {
    if (b.resourceId == resourceId && _isSameDay(b.date, date)) {
      final existingStart = _toMinutes(b.start);
      final existingEnd = _toMinutes(b.end);
      if (newStart < existingEnd && newEnd > existingStart) {
        return false;
      }
    }
  }
  return true;
}

void addBooking(Booking booking) {
  _bookings.add(booking);
}

List<Booking> getBookingsFor(String resourceId, DateTime date) {
  return _bookings
      .where((b) => b.resourceId == resourceId && _isSameDay(b.date, date))
      .toList();
}

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

  final Color _teal = const Color(0xFF008080);
  final double _radius = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _teal,
        elevation: 0,
        centerTitle: true,
        title: const Text('Reserve',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.resourceName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const SizedBox(height: 12),

          // 📅 Date Section
          const Text('Select Date',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          _buildChoiceCard(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [_teal, _teal.withValues(alpha: 0.85)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today, color: Colors.white),
              ),
              title: Text(
                selectedDate == null
                    ? 'Choose Date'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: TextButton(
                onPressed: () async {
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
                        textButtonTheme: TextButtonThemeData(
                          style: ButtonStyle(
                            foregroundColor:
                                WidgetStateProperty.all(_teal), // ✅ teal color
                            overlayColor: WidgetStateProperty.all(
                                _teal.withValues(alpha: 0.1)),
                          ),
                        ),
                      ),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
                child: Text(
                  'Pick',
                  style: TextStyle(
                      color: _teal,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 🕓 Time Section
          const Text('Select Time (Start & End)',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: _buildChoiceCard(
                child: TextButton(
                  onPressed: () async {
                   final picked = await showTealTimePicker(
                    context,
                     initialTime: TimeOfDay.now(),
                         primary: _teal,
                                );

                   if (picked != null) setState(() => startTime = picked);
                   },
                  child: Text(
                    startTime == null ? 'Start Time' : startTime!.format(context),
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: _teal),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChoiceCard(
                child: TextButton(
                  onPressed: () async {
                    final initial = startTime ?? TimeOfDay.now();
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: initial,
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: _teal,
                            onPrimary: Colors.white,
                            onSurface: Colors.black87,
                          ),
                          timePickerTheme: _customTimePickerTheme(),
                        ),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    );
                    if (picked != null) setState(() => endTime = picked);
                  },
                  child: Text(
                    endTime == null ? 'End Time' : endTime!.format(context),
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: _teal),
                  ),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 18),

          // 🧾 Existing bookings
          if (selectedDate != null) ...[
            const Text('Existing bookings for chosen date:',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            for (final b in getBookingsFor(widget.resourceId, selectedDate!))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    _smallTimeBox(b.start.format(context)),
                    const SizedBox(width: 8),
                    const Icon(Icons.remove, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    _smallTimeBox(b.end.format(context)),
                  ],
                ),
              ),
          ],

          const Spacer(),

          // ✅ Book Button → goes to Payment Screen
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onBookPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_radius)),
                elevation: 6,
                shadowColor: _teal.withValues(alpha: 0.12),
              ),
              child: const Text('Book',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  // 🎨 Custom Teal TimePicker theme
  TimePickerThemeData _customTimePickerTheme() {
    return TimePickerThemeData(
      backgroundColor: Colors.white,
      dialHandColor: _teal,
      dialBackgroundColor: _teal.withValues(alpha: 0.08),
      hourMinuteTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : _teal,
      ),
      dialTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : _teal,
      ),
      // ✅ Teal outline for AM/PM box
      dayPeriodShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _teal, width: 1.5),
      ),
      dayPeriodTextColor: WidgetStateColor.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? Colors.white : _teal,
      ),
      dayPeriodColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return _teal;
        if (states.contains(WidgetState.hovered)) {
          return _teal.withValues(alpha: 0.12);
        }
        return Colors.white;
      }),
      helpTextStyle: TextStyle(fontWeight: FontWeight.bold, color: _teal),
    );
  }

  Widget _buildChoiceCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _smallTimeBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(color: _teal, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _onBookPressed() {
    if (selectedDate == null || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please choose date, start time, and end time.')));
      return;
    }

    final s = _toMinutes(startTime!);
    final e = _toMinutes(endTime!);
    if (e <= s) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('End time must be after start time.')));
      return;
    }

    final ok =
        isSlotAvailable(widget.resourceId, selectedDate!, startTime!, endTime!);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Already booked! Try another time or date.')));
      return;
    }

    addBooking(Booking(
        resourceId: widget.resourceId,
        date: selectedDate!,
        start: startTime!,
        end: endTime!));

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentSelectionScreen()),
    );
  }
}
