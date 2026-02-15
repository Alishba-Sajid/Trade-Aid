//wudgets/time_picker.dart
import 'package:flutter/material.dart';

// 🌿 Shared Premium Industrial Palette
const Color industrialTealPrimary = Color.fromARGB(255, 15, 119, 124);
const Color industrialTealSecondary = Color.fromARGB(255, 17, 158, 144);

/// Reusable showTimePicker wrapper with Premium Industrial Palette.
/// Restricts selection to 9:00 AM - 10:59 PM.
Future<TimeOfDay?> showTealTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
  required Color primary,
}) async {
  // Force default to PM if the initial time provided is in the AM
  TimeOfDay startingTime = initialTime.hour < 12 
      ? TimeOfDay(hour: initialTime.hour + 12, minute: initialTime.minute) 
      : initialTime;

  TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: startingTime,
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
            (states) => states.contains(WidgetState.selected) ? Colors.white : industrialTealPrimary,
          ),
          dialTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected) ? Colors.white : industrialTealPrimary,
          ),
          dayPeriodShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: industrialTealPrimary, width: 1.5),
          ),
          dayPeriodTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected) ? Colors.white : industrialTealPrimary,
          ),
          dayPeriodColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return industrialTealPrimary;
            if (states.contains(WidgetState.hovered)) return industrialTealPrimary.withOpacity(0.12);
            return Colors.white;
          }),
          helpTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: industrialTealPrimary),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    ),
  );

  // --- Logic to prevent 11 PM to 9 AM ---
  if (picked != null) {
    final bool isInvalid = picked.hour >= 23 || picked.hour < 9;

    if (isInvalid) {
      // Prominent Alert using MaterialBanner
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          padding: const EdgeInsets.all(12),
          content: const Text(
            "INVALID TIME: Selection between 11:00 PM and 9:00 AM is not allowed.",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          backgroundColor: Colors.redAccent,
          actions: [
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child: const Text("TRY AGAIN", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      // Recursive call: force the user back into the picker
      return showTealTimePicker(context, initialTime: startingTime, primary: primary);
    }
  }
  
  // Clean up any remaining banners if selection is valid
  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  return picked;
}