import 'package:commons/src/charts/rose_geometry.dart';
import 'package:commons/src/charts/rose_slice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

RoseSlice<void> _s(String id, double m) => RoseSlice<void>(
      id: id,
      label: id,
      magnitude: m,
      amountLabel: '$m',
      color: Colors.red,
      onColor: Colors.white,
    );

double _r(double m, [double max = 100]) => roseOuterRadius(
      magnitude: m,
      maxMagnitude: max,
      minRadius: 10,
      maxRadius: 50,
    );

void main() {
  group('roseOuterRadius', () {
    test('zero magnitude is minRadius', () => expect(_r(0), 10));
    test('max magnitude is maxRadius', () => expect(_r(100), 50));
    test('quarter of max is halfway', () => expect(_r(25), closeTo(30, 1e-9)));
    test('negative equals zero', () => expect(_r(-5), _r(0)));
    test('maxMagnitude 0 returns minRadius', () => expect(_r(5, 0), 10));
  });

  group('roseDensity', () {
    int d(double o) => roseDensity(outerRadius: o, chartRadius: 100);
    test('thresholds', () {
      expect(d(75), 2);
      expect(d(74.99), 1);
      expect(d(50), 1);
      expect(d(49.99), 0);
    });
  });

  group('roseCapSlices', () {
    test('15 slices merge into 12', () {
      final slices = [for (var i = 1; i <= 15; i++) _s('s$i', i.toDouble())];
      final out = roseCapSlices<void>(slices);
      expect(out.length, 12);
      expect(out.last.id, '__more__');
      expect(out.last.label, '+4 more');
      expect(out.last.magnitude, 1 + 2 + 3 + 4);
      expect(out.first.magnitude, 15);
    });

    test('12 slices unchanged and sorted descending', () {
      final slices = [for (var i = 1; i <= 12; i++) _s('s$i', i.toDouble())];
      final out = roseCapSlices<void>(slices);
      expect(out.length, 12);
      expect(out.any((s) => s.id == '__more__'), isFalse);
      final mags = out.map((s) => s.magnitude).toList();
      expect(mags, [for (var i = 12; i >= 1; i--) i.toDouble()]);
    });
  });
}
