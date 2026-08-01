import 'package:flutter/material.dart';

/// Miscellaneous [ThemeData] builders (badge, divider, data table, tooltip).
/// Internal to the theme package.
abstract final class MiscThemes {
  static BadgeThemeData badge({required ColorScheme c, required TextTheme t}) {
    return BadgeThemeData(
      backgroundColor: c.error,
      textColor: c.onError,
      textStyle: t.labelSmall,
    );
  }

  static DividerThemeData divider({required ColorScheme c}) {
    return DividerThemeData(
      color: c.outlineVariant,
      thickness: 1,
      space: 1,
    );
  }

  static DataTableThemeData dataTable({
    required ColorScheme c,
    required TextTheme t,
  }) {
    return DataTableThemeData(
      headingTextStyle: t.titleSmall?.copyWith(color: c.onSurfaceVariant),
      dataTextStyle: t.bodyMedium,
      headingRowColor: WidgetStatePropertyAll(c.surfaceContainerHighest),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.outlineVariant)),
      ),
    );
  }

  static TooltipThemeData tooltip({
    required ColorScheme c,
    required TextTheme t,
  }) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: c.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: t.bodySmall?.copyWith(color: c.onInverseSurface),
    );
  }
}
