import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Radial gradient anchored on the chart centre.
class RoseCenteredRadialGradient extends Gradient {
  const RoseCenteredRadialGradient({
    required this.center,
    required this.radius,
    required super.colors,
    super.stops,
  });

  final Offset center;
  final double radius;

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) =>
      ui.Gradient.radial(center, radius, colors, stops);

  @override
  Gradient scale(double factor) => RoseCenteredRadialGradient(
        center: center,
        radius: radius,
        colors: [for (final c in colors) Color.lerp(null, c, factor)!],
        stops: stops,
      );

  @override
  Gradient withOpacity(double opacity) => RoseCenteredRadialGradient(
        center: center,
        radius: radius,
        colors: [for (final c in colors) c.withValues(alpha: c.a * opacity)],
        stops: stops,
      );
}
