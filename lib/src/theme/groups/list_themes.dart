import 'package:flutter/material.dart';

/// List-related [ThemeData] builders (list tiles, expansion tiles).
/// Internal to the theme package.
abstract final class ListThemes {
  static ListTileThemeData listTile({
    required ColorScheme c,
    required TextTheme t,
    required BorderRadius br,
  }) {
    return ListTileThemeData(
      iconColor: c.onSurfaceVariant,
      textColor: c.onSurface,
      tileColor: Colors.transparent,
      selectedTileColor: c.secondaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: br),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: t.bodyLarge,
      subtitleTextStyle: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
    );
  }

  static ExpansionTileThemeData expansionTile({
    required ColorScheme c,
    required TextTheme t,
    required BorderRadius br,
  }) {
    return ExpansionTileThemeData(
      backgroundColor: c.surfaceContainerLow,
      collapsedBackgroundColor: c.surface,
      iconColor: c.onSurfaceVariant,
      collapsedIconColor: c.onSurfaceVariant,
      textColor: c.onSurface,
      collapsedTextColor: c.onSurface,
      shape: RoundedRectangleBorder(borderRadius: br),
      collapsedShape: RoundedRectangleBorder(borderRadius: br),
    );
  }
}
