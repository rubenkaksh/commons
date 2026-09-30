import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/src/theme/color_extensions.dart';

void main() {
  group('OnColor.onColor', () {
    test('white background takes the dark foreground', () {
      expect(Colors.white.onColor(), Colors.black);
    });

    test('black background takes the light foreground', () {
      expect(Colors.black.onColor(), Colors.white);
    });

    test('yellow background takes the dark foreground', () {
      expect(const Color(0xFFFFEB3B).onColor(), Colors.black);
    });

    test('dark blue background takes the light foreground', () {
      expect(const Color(0xFF0D47A1).onColor(), Colors.white);
    });

    test('custom light/dark params are returned verbatim', () {
      const Color customLight = Color(0xFF00FF00);
      const Color customDark = Color(0xFFFF00FF);

      expect(
        Colors.black.onColor(light: customLight, dark: customDark),
        customLight,
      );
      expect(
        Colors.white.onColor(light: customLight, dark: customDark),
        customDark,
      );
    });
  });
}
