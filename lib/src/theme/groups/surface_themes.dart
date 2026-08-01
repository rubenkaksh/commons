import 'package:flutter/material.dart';

/// Surface-related [ThemeData] builders (drawer, card, dialog, bottom sheet,
/// snack bar, banner, chip). Internal to the theme package.
abstract final class SurfaceThemes {
  static DrawerThemeData drawer({required ColorScheme c, required BorderRadius br}) {
    return DrawerThemeData(
      backgroundColor: c.surfaceContainerLow,
      surfaceTintColor: c.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: br),
    );
  }

  static CardThemeData card({
    required ColorScheme c,
    required BorderRadius br,
    required bool isLight,
  }) {
    return CardThemeData(
      elevation: isLight ? 1 : 2,
      color: c.surfaceContainerLow,
      surfaceTintColor: c.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: br),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    );
  }

  static DialogThemeData dialog({
    required ColorScheme c,
    required TextTheme t,
    required BorderRadius dr,
  }) {
    return DialogThemeData(
      backgroundColor: c.surfaceContainerHigh,
      surfaceTintColor: c.surfaceTint,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: dr),
      titleTextStyle: t.headlineSmall?.copyWith(color: c.onSurface),
      contentTextStyle: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
    );
  }

  static BottomSheetThemeData bottomSheet({required ColorScheme c}) {
    return BottomSheetThemeData(
      backgroundColor: c.surfaceContainerHigh,
      surfaceTintColor: c.surfaceTint,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      dragHandleColor: c.onSurfaceVariant,
      showDragHandle: true,
    );
  }

  static SnackBarThemeData snackBar({
    required ColorScheme c,
    required TextTheme t,
    required BorderRadius br,
  }) {
    return SnackBarThemeData(
      backgroundColor: c.inverseSurface,
      contentTextStyle: t.bodyMedium?.copyWith(color: c.onInverseSurface),
      actionTextColor: c.inversePrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: br),
    );
  }

  static MaterialBannerThemeData banner({
    required ColorScheme c,
    required TextTheme t,
  }) {
    return MaterialBannerThemeData(
      backgroundColor: c.surfaceContainerHigh,
      contentTextStyle: t.bodyMedium,
    );
  }

  static ChipThemeData chip({required ColorScheme c, required TextTheme t}) {
    return ChipThemeData(
      backgroundColor: c.surfaceContainerHighest,
      deleteIconColor: c.onSurfaceVariant,
      disabledColor: c.onSurface.withValues(alpha: 0.12),
      selectedColor: c.secondaryContainer,
      secondarySelectedColor: c.tertiaryContainer,
      labelStyle: t.labelLarge,
      secondaryLabelStyle: t.labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: c.outline),
    );
  }
}
