import 'package:flutter/material.dart';

// 🌿 Shared Premium Industrial Palette
const Color industrialTealPrimary = Color.fromARGB(255, 15, 119, 124);
const Color industrialTealSecondary = Color.fromARGB(255, 17, 158, 144);

/// Reusable showTimePicker wrapper with Premium Industrial Palette.
/// Restricts selection to avoid 12:30 AM - 6:00 AM.
Future<TimeOfDay?> showTealTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
  required Color primary,
}) async {
  TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (ctx, child) => Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.light(
          primary: industrialTealPrimary,
          onPrimary: Colors.white,
          onSurface: Colors.black87,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          dialHandColor: industrialTealPrimary,
          dialBackgroundColor: industrialTealPrimary.withOpacity(0.08),
          hourMinuteTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : industrialTealPrimary,
          ),
          dialTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : industrialTealPrimary,
          ),
          dayPeriodShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: industrialTealPrimary, width: 1.5),
          ),
          dayPeriodTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : industrialTealPrimary,
          ),
          dayPeriodColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return industrialTealPrimary;
            if (states.contains(WidgetState.hovered)) {
              return industrialTealPrimary.withOpacity(0.12);
            }
            return Colors.white;
          }),
          helpTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: industrialTealPrimary,
          ),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    ),
  );

  if (picked != null) {
    // Logic for 12:30 AM to 6:00 AM restriction
    // 12:30 AM is hour 0, minute 30. 6:00 AM is hour 6, minute 0.
    final int pickedMinutes = picked.hour * 60 + picked.minute;
    const int startInMinutes = 30; // 00:30 (12:30 AM)
    const int endInMinutes = 360; // 06:00 (6:00 AM)

    bool isInvalid = pickedMinutes >= startInMinutes && pickedMinutes < endInMinutes;

    if (isInvalid) {
      // Enhanced UI Warning: Floating SnackBar that appears for 2 seconds
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: const Row(
            children: [
              Icon(Icons.timer_off, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Selection not allowed between 12:30 AM and 6:00 AM.",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );

      // Recursive call: force the user back into the picker
      return showTealTimePicker(context, initialTime: initialTime, primary: primary);
    }
  }

  return picked;
}