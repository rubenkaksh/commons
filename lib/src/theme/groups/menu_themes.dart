import 'package:flutter/material.dart';

/// Menu-related [ThemeData] builders (popup menu, menu, menu bar).
/// Internal to the theme package.
abstract final class MenuThemes {
  static PopupMenuThemeData popupMenu({
    required ColorScheme c,
    required TextTheme t,
    required BorderRadius br,
  }) {
    return PopupMenuThemeData(
      color: c.surfaceContainer,
      surfaceTintColor: c.surfaceTint,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: br),
      textStyle: t.bodyLarge,
    );
  }

  static MenuThemeData menu({required ColorScheme c, required BorderRadius br}) {
    return MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(c.surfaceContainer),
        surfaceTintColor: WidgetStatePropertyAll(c.surfaceTint),
        elevation: const WidgetStatePropertyAll(3),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: br)),
      ),
    );
  }

  static MenuBarThemeData menuBar({required ColorScheme c}) {
    return MenuBarThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(c.surfaceContainer),
        elevation: const WidgetStatePropertyAll(2),
      ),
    );
  }
}
