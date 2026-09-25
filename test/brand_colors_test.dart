import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/commons.dart';

ThemeData _theme(Brightness b, {BrandColors? brand}) => ComponentThemes.build(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: b),
  textTheme: const TextTheme(),
  brightness: b,
  brandColors: brand,
);

void main() {
  test('light and dark defaults differ', () {
    expect(BrandColors.light.success, isNot(BrandColors.dark.success));
    expect(BrandColors.light.warning, isNot(BrandColors.dark.warning));
    expect(BrandColors.light.info, isNot(BrandColors.dark.info));
  });

  test('copyWith replaces only the given fields', () {
    final BrandColors c = BrandColors.light.copyWith(success: Colors.black);
    expect(c.success, Colors.black);
    expect(c.onSuccess, BrandColors.light.onSuccess);
    expect(c.warning, BrandColors.light.warning);
    expect(c.onWarning, BrandColors.light.onWarning);
    expect(c.info, BrandColors.light.info);
    expect(c.onInfo, BrandColors.light.onInfo);
  });

  test('lerp interpolates every field and ignores foreign extensions', () {
    const BrandColors a = BrandColors(
      success: Color(0xFF000000), onSuccess: Color(0xFF000000),
      warning: Color(0xFF000000), onWarning: Color(0xFF000000),
      info: Color(0xFF000000), onInfo: Color(0xFF000000),
    );
    const BrandColors b = BrandColors(
      success: Color(0xFFFFFFFF), onSuccess: Color(0xFFFFFFFF),
      warning: Color(0xFFFFFFFF), onWarning: Color(0xFFFFFFFF),
      info: Color(0xFFFFFFFF), onInfo: Color(0xFFFFFFFF),
    );
    final BrandColors mid = a.lerp(b, 0.5);
    for (final Color c in <Color>[mid.success, mid.onSuccess, mid.warning, mid.onWarning, mid.info, mid.onInfo]) {
      expect(c, Color.lerp(const Color(0xFF000000), const Color(0xFFFFFFFF), 0.5));
    }
    expect(identical(a.lerp(null, 0.5), a), isTrue);
  });

  test('ComponentThemes.build registers the brightness default', () {
    expect(_theme(Brightness.light).extension<BrandColors>(), BrandColors.light);
    expect(_theme(Brightness.dark).extension<BrandColors>(), BrandColors.dark);
  });

  test('ComponentThemes.build registers a supplied BrandColors', () {
    final BrandColors custom = BrandColors.light.copyWith(info: Colors.pink);
    expect(_theme(Brightness.light, brand: custom).extension<BrandColors>(), custom);
  });

  testWidgets('BrandColors.of reads the theme, falling back by brightness', (WidgetTester tester) async {
    late BrandColors found;
    Widget probe() => Builder(builder: (BuildContext c) {
      found = BrandColors.of(c);
      return const SizedBox();
    });

    await tester.pumpWidget(MaterialApp(theme: ThemeData(brightness: Brightness.dark), home: probe()));
    expect(found, BrandColors.dark);

    final BrandColors custom = BrandColors.light.copyWith(info: Colors.pink);
    await tester.pumpWidget(MaterialApp(theme: _theme(Brightness.light, brand: custom), home: probe()));
    await tester.pumpAndSettle();
    expect(found, custom);
  });
}
