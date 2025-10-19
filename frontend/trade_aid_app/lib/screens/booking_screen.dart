import 'package:flutter/material.dart';

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

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

bool isSlotAvailable(String resourceId, DateTime date, TimeOfDay start, TimeOfDay end) {
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
  return _bookings.where((b) => b.resourceId == resourceId && _isSameDay(b.date, date)).toList();
}

class BookingScreen extends StatefulWidget {
  final String resourceId;
  final String resourceName;

  const BookingScreen({super.key, required this.resourceId, required this.resourceName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, title: const Text('Reserve'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.resourceName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final today = DateTime.now();
              final picked = await showDatePicker(context: context, initialDate: selectedDate ?? today, firstDate: today, lastDate: today.add(const Duration(days: 365)));
              if (picked != null) setState(() => selectedDate = picked);
            },
            child: Text(selectedDate == null ? 'Choose Date' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
          ),
          const SizedBox(height: 20),
          const Text('Select Time (Start & End)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (picked != null) setState(() => startTime = picked);
                },
                child: Text(startTime == null ? 'Start Time' : startTime!.format(context)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final initial = startTime ?? TimeOfDay.now();
                  final picked = await showTimePicker(context: context, initialTime: initial);
                  if (picked != null) setState(() => endTime = picked);
                },
                child: Text(endTime == null ? 'End Time' : endTime!.format(context)),
              ),
            ),
          ]),
          const SizedBox(height: 18),
          if (selectedDate != null) ...[
            const Text('Existing bookings for chosen date:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            for (final b in getBookingsFor(widget.resourceId, selectedDate!)) ...[
              Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Text('• ${b.start.format(context)} - ${b.end.format(context)}')),
            ],
            const SizedBox(height: 12),
          ],
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: const Color(0xFF008080)),
            onPressed: () {
              if (selectedDate == null || startTime == null || endTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please choose date, start time, and end time.')));
                return;
              }

              final s = _toMinutes(startTime!);
              final e = _toMinutes(endTime!);
              if (e <= s) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End time must be after start time.')));
                return;
              }

              final ok = isSlotAvailable(widget.resourceId, selectedDate!, startTime!, endTime!);
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Already booked! Try another time or date.')));
                return;
              }

              addBooking(Booking(resourceId: widget.resourceId, date: selectedDate!, start: startTime!, end: endTime!));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking successful!')));
              Navigator.pop(context);
            },
            child: const Text('Book'),
          ),
        ]),
      ),
    );
  }
}
