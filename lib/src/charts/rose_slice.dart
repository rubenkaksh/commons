import 'package:flutter/material.dart';

/// One wedge of a [RoseChart].
///
/// [magnitude] is a non-negative size; negative values are treated as 0 by
/// the geometry. [amountLabel] is preformatted by the caller.
class RoseSlice<T> {
  const RoseSlice({
    required this.id,
    required this.label,
    required this.magnitude,
    required this.amountLabel,
    required this.color,
    required this.onColor,
    this.icon,
    this.data,
  });

  final String id;
  final String label;
  final double magnitude;
  final String amountLabel;
  final Color color;
  final Color onColor;
  final IconData? icon;
  final T? data;
}
