import 'package:flutter/material.dart';

/// Picker-related [ThemeData] builders (date and time pickers).
/// Internal to the theme package.
abstract final class PickerThemes {
  static DatePickerThemeData datePicker({
    required ColorScheme c,
    required TextTheme t,
  }) {
    return DatePickerThemeData(
      backgroundColor: c.surfaceContainerHigh,
      headerBackgroundColor: c.primaryContainer,
      headerForegroundColor: c.onPrimaryContainer,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? c.onPrimary : c.onSurface;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? c.primary : null;
      }),
      todayForegroundColor: WidgetStatePropertyAll(c.primary),
      todayBackgroundColor: WidgetStatePropertyAll(
        c.primaryContainer.withValues(alpha: 0.4),
      ),
    );
  }

  static TimePickerThemeData timePicker({required ColorScheme c}) {
    return TimePickerThemeData(
      backgroundColor: c.surfaceContainerHigh,
      hourMinuteColor: c.surfaceContainerHighest,
      hourMinuteTextColor: c.onSurface,
      dialBackgroundColor: c.primaryContainer,
      dialHandColor: c.primary,
      entryModeIconColor: c.onSurfaceVariant,
    );
  }
}
