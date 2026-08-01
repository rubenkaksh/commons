import 'package:flutter/material.dart';

import 'groups/button_themes.dart';
import 'groups/input_themes.dart';
import 'groups/list_themes.dart';
import 'groups/menu_themes.dart';
import 'groups/misc_themes.dart';
import 'groups/navigation_themes.dart';
import 'groups/picker_themes.dart';
import 'groups/selection_themes.dart';
import 'groups/surface_themes.dart';

/// Assembles the full set of Material 3 component themes for the shared
/// design system.
///
/// Deliberately palette-agnostic: the caller owns the [ColorScheme] (usually
/// generated from the app's own brand seeds) and the [TextTheme] (via
/// [AppTypography]). Shape values are parameterized with defaults so apps can
/// override radii without forking this file.
abstract final class ComponentThemes {
  /// Default corner radius used across surfaces, inputs and list items.
  static const BorderRadius defaultRadius = BorderRadius.all(
    Radius.circular(12),
  );

  /// Default button shape (fully rounded, 20dp corners).
  static const OutlinedBorder defaultButtonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );

  static ThemeData build({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Brightness brightness,
    BorderRadius borderRadius = defaultRadius,
    OutlinedBorder buttonShape = defaultButtonShape,
  }) {
    final bool isLight = brightness == Brightness.light;
    const BorderRadius dialogRadius = BorderRadius.all(Radius.circular(28));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surfaceContainerLow,
      dividerColor: colorScheme.outlineVariant,
      splashColor: colorScheme.primary.withValues(alpha: 0.12),
      highlightColor: colorScheme.primary.withValues(alpha: 0.08),
      appBarTheme: NavigationThemes.appBar(
        c: colorScheme,
        t: textTheme,
      ),
      navigationBarTheme: NavigationThemes.navigationBar(
        c: colorScheme,
        t: textTheme,
      ),
      navigationRailTheme: NavigationThemes.navigationRail(
        c: colorScheme,
        t: textTheme,
      ),
      navigationDrawerTheme: NavigationThemes.navigationDrawer(
        c: colorScheme,
        t: textTheme,
      ),
      bottomNavigationBarTheme: NavigationThemes.bottomNavigationBar(
        c: colorScheme,
      ),
      tabBarTheme: NavigationThemes.tabBar(c: colorScheme, t: textTheme),
      drawerTheme: SurfaceThemes.drawer(c: colorScheme, br: borderRadius),
      cardTheme: SurfaceThemes.card(
        c: colorScheme,
        br: borderRadius,
        isLight: isLight,
      ),
      dialogTheme: SurfaceThemes.dialog(
        c: colorScheme,
        t: textTheme,
        dr: dialogRadius,
      ),
      bottomSheetTheme: SurfaceThemes.bottomSheet(c: colorScheme),
      snackBarTheme: SurfaceThemes.snackBar(
        c: colorScheme,
        t: textTheme,
        br: borderRadius,
      ),
      bannerTheme: SurfaceThemes.banner(c: colorScheme, t: textTheme),
      chipTheme: SurfaceThemes.chip(c: colorScheme, t: textTheme),
      elevatedButtonTheme: ButtonThemes.elevated(
        c: colorScheme,
        t: textTheme,
        shape: buttonShape,
      ),
      filledButtonTheme: ButtonThemes.filled(
        c: colorScheme,
        t: textTheme,
        shape: buttonShape,
      ),
      outlinedButtonTheme: ButtonThemes.outlined(
        c: colorScheme,
        t: textTheme,
        shape: buttonShape,
      ),
      textButtonTheme: ButtonThemes.text(c: colorScheme, t: textTheme),
      segmentedButtonTheme: ButtonThemes.segmented(),
      iconButtonTheme: ButtonThemes.iconButton(c: colorScheme),
      floatingActionButtonTheme: ButtonThemes.fab(c: colorScheme),
      inputDecorationTheme: InputThemes.decoration(
        c: colorScheme,
        t: textTheme,
        br: borderRadius,
      ),
      dropdownMenuTheme: InputThemes.dropdownMenu(
        t: textTheme,
        br: borderRadius,
      ),
      searchBarTheme: InputThemes.searchBar(c: colorScheme, t: textTheme),
      searchViewTheme: InputThemes.searchView(c: colorScheme, t: textTheme),
      checkboxTheme: SelectionThemes.checkbox(c: colorScheme),
      radioTheme: SelectionThemes.radio(c: colorScheme),
      switchTheme: SelectionThemes.switchTheme(c: colorScheme),
      sliderTheme: SelectionThemes.slider(c: colorScheme, t: textTheme),
      progressIndicatorTheme: SelectionThemes.progress(c: colorScheme),
      listTileTheme: ListThemes.listTile(
        c: colorScheme,
        t: textTheme,
        br: borderRadius,
      ),
      expansionTileTheme: ListThemes.expansionTile(
        c: colorScheme,
        t: textTheme,
        br: borderRadius,
      ),
      popupMenuTheme: MenuThemes.popupMenu(
        c: colorScheme,
        t: textTheme,
        br: borderRadius,
      ),
      menuTheme: MenuThemes.menu(c: colorScheme, br: borderRadius),
      menuBarTheme: MenuThemes.menuBar(c: colorScheme),
      badgeTheme: MiscThemes.badge(c: colorScheme, t: textTheme),
      dividerTheme: MiscThemes.divider(c: colorScheme),
      dataTableTheme: MiscThemes.dataTable(c: colorScheme, t: textTheme),
      datePickerTheme: PickerThemes.datePicker(c: colorScheme, t: textTheme),
      timePickerTheme: PickerThemes.timePicker(c: colorScheme),
      tooltipTheme: MiscThemes.tooltip(c: colorScheme, t: textTheme),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
