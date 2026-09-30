import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A divider drawn as a repeating dash pattern along an axis.
///
/// The widget is sized to `double.infinity` along [axis] and to exactly
/// [thickness] across it, so it fills the cross axis it is given (e.g. the
/// full width of a `Column` for the default horizontal axis) without any
/// `ListView`, `MediaQuery` look-up or hard-coded dot count.
///
/// ```dart
/// const DottedDivider();                        // horizontal, theme colour
/// const DottedDivider(axis: Axis.vertical);     // vertical dash column
/// ```
class DottedDivider extends StatelessWidget {
  /// Creates a dash-patterned divider with sensible defaults for every knob.
  const DottedDivider({
    super.key,
    this.axis = Axis.horizontal,
    this.thickness = 1.5,
    this.dashLength = 4,
    this.gap = 3,
    this.color,
  });

  /// Direction the dashes run in. Defaults to [Axis.horizontal].
  final Axis axis;

  /// Stroke width of each dash, in logical pixels. Defaults to `1.5`.
  final double thickness;

  /// Length of a single dash along [axis], in logical pixels. Defaults to `4`.
  final double dashLength;

  /// Clear space between consecutive dashes, in logical pixels. Defaults to
  /// `3`.
  final double gap;

  /// Colour of the dashes. When `null` (the default) the divider uses
  /// `Theme.of(context).colorScheme.outlineVariant`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color resolvedColor =
        color ?? Theme.of(context).colorScheme.outlineVariant;
    final bool isHorizontal = axis == Axis.horizontal;
    return SizedBox(
      width: isHorizontal ? double.infinity : thickness,
      height: isHorizontal ? thickness : double.infinity,
      child: CustomPaint(
        painter: DottedDividerPainter(
          color: resolvedColor,
          axis: axis,
          thickness: thickness,
          dashLength: dashLength,
          gap: gap,
        ),
      ),
    );
  }
}

/// Paints the dash pattern for [DottedDivider].
///
/// Annotated `visibleForTesting` so widget tests can read back the colour the
/// widget resolved from the theme; it is not intended as public API.
@visibleForTesting
class DottedDividerPainter extends CustomPainter {
  /// Creates a painter from the resolved colour and dash geometry.
  const DottedDividerPainter({
    required this.color,
    required this.axis,
    required this.thickness,
    required this.dashLength,
    required this.gap,
  });

  /// The resolved dash colour (theme `outlineVariant` unless overridden).
  final Color color;

  /// Direction the dashes run in.
  final Axis axis;

  /// Stroke width of each dash.
  final double thickness;

  /// Length of a single dash along [axis].
  final double dashLength;

  /// Clear space between consecutive dashes.
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final bool isHorizontal = axis == Axis.horizontal;
    final double extent = isHorizontal ? size.width : size.height;
    final double crossExtent = isHorizontal ? size.height : size.width;
    final double stride = dashLength + gap;
    if (extent <= 0 || crossExtent <= 0 || stride <= 0) {
      return;
    }
    final double center = crossExtent / 2;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;
    for (double offset = 0; offset < extent; offset += stride) {
      final double end = math.min(offset + dashLength, extent);
      if (isHorizontal) {
        canvas.drawLine(Offset(offset, center), Offset(end, center), paint);
      } else {
        canvas.drawLine(Offset(center, offset), Offset(center, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DottedDividerPainter oldDelegate) {
    return color != oldDelegate.color ||
        axis != oldDelegate.axis ||
        thickness != oldDelegate.thickness ||
        dashLength != oldDelegate.dashLength ||
        gap != oldDelegate.gap;
  }
}
