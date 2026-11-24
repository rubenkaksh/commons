import 'dart:math' as math;

import 'rose_slice.dart';

/// Outer radius of a wedge, scaled by the square root of its magnitude.
double roseOuterRadius({
  required double magnitude,
  required double maxMagnitude,
  required double minRadius,
  required double maxRadius,
}) {
  if (maxMagnitude <= 0) return minRadius;
  return minRadius +
      (maxRadius - minRadius) *
          math.sqrt(math.max(magnitude, 0) / maxMagnitude);
}

/// 2 = full, 1 = compact, 0 = minimal.
int roseDensity({required double outerRadius, required double chartRadius}) {
  if (outerRadius >= 0.75 * chartRadius) return 2;
  if (outerRadius >= 0.5 * chartRadius) return 1;
  return 0;
}

/// Sorts a copy by magnitude descending and merges the tail into a single
/// `__more__` slice when there are more than [maxWedges] slices.
List<RoseSlice<T>> roseCapSlices<T>(
  List<RoseSlice<T>> slices, {
  int maxWedges = 12,
}) {
  double mag(RoseSlice<T> s) => math.max(s.magnitude, 0);
  final sorted = [...slices]..sort((a, b) => mag(b).compareTo(mag(a)));
  if (sorted.length <= maxWedges) return sorted;

  final kept = sorted.sublist(0, maxWedges - 1);
  final merged = sorted.sublist(maxWedges - 1);
  final sum = merged.fold<double>(0, (acc, s) => acc + mag(s));
  return [
    ...kept,
    RoseSlice<T>(
      id: '__more__',
      label: '+${merged.length} more',
      magnitude: math.max(sum, 0),
      amountLabel: '',
      color: merged.first.color,
      onColor: merged.first.onColor,
    ),
  ];
}
