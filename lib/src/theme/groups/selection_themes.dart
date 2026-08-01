import 'package:flutter/material.dart';

/// Selection and progress [ThemeData] builders (checkbox, radio, switch,
/// slider, progress indicators). Internal to the theme package.
abstract final class SelectionThemes {
  static CheckboxThemeData checkbox({required ColorScheme c}) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
          ? c.primary
          : c.surfaceContainerHighest;
      }),
      checkColor: WidgetStatePropertyAll(c.onPrimary),
      side: BorderSide(color: c.outline, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  static RadioThemeData radio({required ColorScheme c}) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
          ? c.primary
          : c.onSurfaceVariant;
      }),
    );
  }

  static SwitchThemeData switchTheme({required ColorScheme c}) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
          ? c.onPrimary
          : c.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
          ? c.primary
          : c.surfaceContainerHighest;
      }),
    );
  }

  static SliderThemeData slider({required ColorScheme c, required TextTheme t}) {
    return SliderThemeData(
      activeTrackColor: c.primary,
      inactiveTrackColor: c.surfaceContainerHighest,
      thumbColor: c.primary,
      overlayColor: c.primary.withValues(alpha: 0.12),
      valueIndicatorColor: c.inverseSurface,
      valueIndicatorTextStyle:
          t.labelMedium?.copyWith(color: c.onInverseSurface),
    );
  }

  static ProgressIndicatorThemeData progress({required ColorScheme c}) {
    return ProgressIndicatorThemeData(
      color: c.primary,
      linearTrackColor: c.surfaceContainerHighest,
      circularTrackColor: c.surfaceContainerHighest,
    );
  }
}
