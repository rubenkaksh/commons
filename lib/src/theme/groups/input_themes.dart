import 'package:flutter/material.dart';

/// Input-related [ThemeData] builders (input decoration, dropdown menu,
/// search bar/view). Internal to the theme package.
abstract final class InputThemes {
  static InputDecorationTheme decoration({
    required ColorScheme c,
    required TextTheme t,
    required BorderRadius br,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: br,
        borderSide: BorderSide(color: c.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: br,
        borderSide: BorderSide(color: c.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: br,
        borderSide: BorderSide(color: c.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: br,
        borderSide: BorderSide(color: c.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: br,
        borderSide: BorderSide(color: c.error, width: 2),
      ),
      labelStyle: t.bodyLarge?.copyWith(color: c.onSurfaceVariant),
      hintStyle: t.bodyLarge?.copyWith(
        color: c.onSurfaceVariant.withValues(alpha: 0.7),
      ),
      floatingLabelStyle: t.bodySmall?.copyWith(color: c.primary),
    );
  }

  static DropdownMenuThemeData dropdownMenu({
    required TextTheme t,
    required BorderRadius br,
  }) {
    return DropdownMenuThemeData(
      textStyle: t.bodyLarge,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.bodyLarge?.color,
        border: OutlineInputBorder(borderRadius: br),
      ),
    );
  }

  static SearchBarThemeData searchBar({required ColorScheme c, required TextTheme t}) {
    return SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(c.surfaceContainerHighest),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(t.bodyLarge),
      hintStyle: WidgetStatePropertyAll(
        t.bodyLarge?.copyWith(color: c.onSurfaceVariant),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }

  static SearchViewThemeData searchView({required ColorScheme c, required TextTheme t}) {
    return SearchViewThemeData(
      backgroundColor: c.surfaceContainerHigh,
      headerTextStyle: t.titleMedium,
      headerHintStyle: t.bodyLarge,
    );
  }
}
