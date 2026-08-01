import 'package:flutter/material.dart';

/// Navigation-related [ThemeData] builders (app bars, navigation bars/rails,
/// drawers, tab bars). Internal to the theme package.
abstract final class NavigationThemes {
  static AppBarTheme appBar({required ColorScheme c, required TextTheme t}) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 3,
      centerTitle: false,
      backgroundColor: c.surface,
      foregroundColor: c.onSurface,
      surfaceTintColor: c.surfaceTint,
      titleTextStyle: t.titleLarge?.copyWith(color: c.onSurface),
      iconTheme: IconThemeData(color: c.onSurfaceVariant),
    );
  }

  static NavigationBarThemeData navigationBar({
    required ColorScheme c,
    required TextTheme t,
  }) {
    return NavigationBarThemeData(
      elevation: 3,
      height: 80,
      backgroundColor: c.surfaceContainer,
      indicatorColor: c.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return t.labelMedium?.copyWith(
          color: states.contains(WidgetState.selected)
            ? c.onSecondaryContainer
            : c.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
            ? c.onSecondaryContainer
            : c.onSurfaceVariant,
        );
      }),
    );
  }

  static NavigationRailThemeData navigationRail({
    required ColorScheme c,
    required TextTheme t,
  }) {
    return NavigationRailThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.secondaryContainer,
      selectedIconTheme: IconThemeData(color: c.onSecondaryContainer),
      unselectedIconTheme: IconThemeData(color: c.onSurfaceVariant),
      selectedLabelTextStyle: t.labelMedium?.copyWith(color: c.onSurface),
      unselectedLabelTextStyle:
          t.labelMedium?.copyWith(color: c.onSurfaceVariant),
    );
  }

  static NavigationDrawerThemeData navigationDrawer({
    required ColorScheme c,
    required TextTheme t,
  }) {
    return NavigationDrawerThemeData(
      backgroundColor: c.surfaceContainerLow,
      indicatorColor: c.secondaryContainer,
      elevation: 1,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return t.labelLarge?.copyWith(
          color: states.contains(WidgetState.selected)
            ? c.onSecondaryContainer
            : c.onSurface,
        );
      }),
    );
  }

  static BottomNavigationBarThemeData bottomNavigationBar({
    required ColorScheme c,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: c.surfaceContainer,
      selectedItemColor: c.onSecondaryContainer,
      unselectedItemColor: c.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 3,
    );
  }

  static TabBarThemeData tabBar({required ColorScheme c, required TextTheme t}) {
    return TabBarThemeData(
      labelColor: c.primary,
      unselectedLabelColor: c.onSurfaceVariant,
      indicatorColor: c.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: t.titleSmall,
      unselectedLabelStyle: t.titleSmall,
      dividerColor: c.outlineVariant,
    );
  }
}
