import 'package:flutter/material.dart';

/// Button-related [ThemeData] builders for the shared design system.
///
/// Internal to the theme package: consumers assemble everything via
/// [ComponentThemes.build] in `component_themes.dart`.
abstract final class ButtonThemes {
  static ElevatedButtonThemeData elevated({
    required ColorScheme c,
    required TextTheme t,
    required OutlinedBorder shape,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: shape,
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        textStyle: t.labelLarge,
      ),
    );
  }

  static FilledButtonThemeData filled({
    required ColorScheme c,
    required TextTheme t,
    required OutlinedBorder shape,
  }) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: shape,
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        textStyle: t.labelLarge,
      ),
    );
  }

  static OutlinedButtonThemeData outlined({
    required ColorScheme c,
    required TextTheme t,
    required OutlinedBorder shape,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: shape,
        foregroundColor: c.primary,
        side: BorderSide(color: c.outline),
        textStyle: t.labelLarge,
      ),
    );
  }

  static TextButtonThemeData text({required ColorScheme c, required TextTheme t}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        foregroundColor: c.primary,
        textStyle: t.labelLarge,
      ),
    );
  }

  static SegmentedButtonThemeData segmented() {
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  static IconButtonThemeData iconButton({required ColorScheme c}) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: c.onSurfaceVariant,
        highlightColor: c.primary.withValues(alpha: 0.12),
      ),
    );
  }

  static FloatingActionButtonThemeData fab({required ColorScheme c}) {
    return FloatingActionButtonThemeData(
      backgroundColor: c.primaryContainer,
      foregroundColor: c.onPrimaryContainer,
      elevation: 3,
      highlightElevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
