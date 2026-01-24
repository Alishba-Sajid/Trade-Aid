import 'package:flutter/material.dart';

/// Reusable showTimePicker wrapper that applies the app's teal theme
/// and the custom TimePickerThemeData used across the app.
///
/// Usage:
/// final picked = await showTealTimePicker(context,
///     initialTime: initial, primary: _teal);
Future<TimeOfDay?> showTealTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
  required Color primary,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (ctx, child) => Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: ColorScheme.light(
          primary: primary, // dial & buttons
          onPrimary: Colors.white, // selected text
          onSurface: Colors.black87, // default text
        ),
        // Keep the custom time picker theme you used before:
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          dialHandColor: primary,
          dialBackgroundColor: primary.withOpacity(0.08),
          hourMinuteTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected) ? Colors.white : primary,
          ),
          dialTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected) ? Colors.white : primary,
          ),
          dayPeriodShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: primary, width: 1.5),
          ),
          dayPeriodTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected) ? Colors.white : primary,
          ),
          dayPeriodColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primary;
            if (states.contains(WidgetState.hovered)) return primary.withOpacity(0.12);
            return Colors.white;
          }),
          helpTextStyle: TextStyle(fontWeight: FontWeight.bold, color: primary),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    ),
  );
}