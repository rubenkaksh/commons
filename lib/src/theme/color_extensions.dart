import 'package:flutter/material.dart';

/// Contrast helpers for arbitrary background colours.
extension OnColor on Color {
  /// A legible foreground for text/icons drawn on this colour: [dark] when
  /// this colour is light, else [light].
  ///
  /// Brightness is decided by [ThemeData.estimateBrightnessForColor], Material's
  /// own contrast heuristic (a 0.15 WCAG-derived threshold), rather than a raw
  /// 0.5 luminance cut-off.
  ///
  /// The black/white literals used as the parameter defaults are the single
  /// documented exception to this package's "no colour literals in lib/" theme
  /// rule: they are the neutral fallback values themselves, not a theme
  /// decision, so they cannot come from Theme.of(context).
  Color onColor({
    Color light = const Color(0xFFFFFFFF),
    Color dark = const Color(0xFF000000),
  }) {
    return ThemeData.estimateBrightnessForColor(this) == Brightness.light
        ? dark
        : light;
  }
}
