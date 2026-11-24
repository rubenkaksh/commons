import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'rose_geometry.dart';
import 'rose_gradient.dart';
import 'rose_slice.dart';

/// Generic rose chart: equal-angle wedges whose radius scales with the
/// square root of each slice's magnitude.
class RoseChart<T> extends StatefulWidget {
  const RoseChart({
    super.key,
    required this.slices,
    this.centerBuilder,
    this.selectedId,
    this.onSliceTap,
    this.backgroundColor = Colors.transparent,
    this.startGapDegrees = 72,
    this.maxWedges = 12,
    this.showPercent = true,
  });

  final List<RoseSlice<T>> slices;

  /// Draws the centre disc, sized `2 * centerSpaceRadius`.
  final Widget Function(double diameter)? centerBuilder;

  /// Externally highlighted slice id; others are dimmed.
  final String? selectedId;

  /// Fired on tap up over a real wedge (not the gap or the `__more__` slice).
  final void Function(RoseSlice<T> slice)? onSliceTap;
  final Color backgroundColor;
  final double startGapDegrees;
  final int maxWedges;
  final bool showPercent;

  @override
  State<RoseChart<T>> createState() => _RoseChartState<T>();
}

class _RoseChartState<T> extends State<RoseChart<T>> {
  @override
  Widget build(BuildContext context) {
    final slices = roseCapSlices<T>(widget.slices, maxWedges: widget.maxWedges);
    final n = slices.length;
    double mag(RoseSlice<T> s) => math.max(s.magnitude, 0);
    final total = slices.fold<double>(0, (sum, s) => sum + mag(s));
    final maxMagnitude = slices.isEmpty ? 0.0 : slices.map(mag).reduce(math.max);

    return ColoredBox(
      color: widget.backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.min(
            math.min(constraints.maxWidth, constraints.maxHeight),
            720.0,
          );
          if (side <= 0) return const SizedBox.shrink();
          final r = side / 2 / 1.08;
          final centerSpace = 0.12 * r;
          final minR = 0.38 * r;
          final maxR = 1.0 * r;
          final centre = Offset(side / 2, side / 2);
          final spacer =
              n * widget.startGapDegrees / (360 - widget.startGapDegrees);

          final sections = <PieChartSectionData>[
            for (final s in slices)
              _section(
                slice: s,
                total: total,
                maxMagnitude: maxMagnitude,
                r: r,
                minR: minR,
                maxR: maxR,
                centerSpace: centerSpace,
                centre: centre,
              ),
            PieChartSectionData(
              value: spacer,
              radius: 1,
              showTitle: false,
              color: const Color(0x00000000),
            ),
          ];

          return Center(
            child: SizedBox(
              width: side,
              height: side,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 2,
                      centerSpaceRadius: centerSpace,
                      sections: sections,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) =>
                            _onTouch(event, response, slices),
                      ),
                    ),
                    duration: const Duration(milliseconds: 150),
                  ),
                  if (widget.centerBuilder != null)
                    IgnorePointer(
                      child: Center(
                        child: SizedBox(
                          width: centerSpace * 2,
                          height: centerSpace * 2,
                          child: widget.centerBuilder!(centerSpace * 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PieChartSectionData _section({
    required RoseSlice<T> slice,
    required double total,
    required double maxMagnitude,
    required double r,
    required double minR,
    required double maxR,
    required double centerSpace,
    required Offset centre,
  }) {
    final magnitude = math.max(slice.magnitude, 0.0);
    final outer = roseOuterRadius(
      magnitude: magnitude,
      maxMagnitude: maxMagnitude,
      minRadius: minR,
      maxRadius: maxR,
    );
    final dimmed = widget.selectedId != null && widget.selectedId != slice.id;
    final percent = total <= 0 ? 0 : (magnitude / total * 100).round();
    final density = roseDensity(outerRadius: outer, chartRadius: r);
    return PieChartSectionData(
      value: 1,
      radius: outer - centerSpace,
      showTitle: false,
      color: slice.color,
      gradient: RoseCenteredRadialGradient(
        center: centre,
        radius: outer,
        colors: [slice.color.withValues(alpha: 0.85), slice.color],
        stops: [centerSpace / outer, 1.0],
      ).withOpacity(dimmed ? 0.4 : 1.0),
      badgeWidget: _Badge(
        slice: slice,
        percent: percent,
        density: density,
        showPercent: widget.showPercent,
      ),
      badgePositionPercentageOffset: 0.6,
    );
  }

  void _onTouch(
    FlTouchEvent event,
    PieTouchResponse? response,
    List<RoseSlice<T>> slices,
  ) {
    if (event is! FlTapUpEvent) return;
    final index = response?.touchedSection?.touchedSectionIndex ?? -1;
    if (index < 0 || index >= slices.length) return;
    final slice = slices[index];
    if (slice.id == '__more__') return;
    widget.onSliceTap?.call(slice);
  }
}

class _Badge<T> extends StatelessWidget {
  const _Badge({
    required this.slice,
    required this.percent,
    required this.density,
    required this.showPercent,
  });

  final RoseSlice<T> slice;
  final int percent;

  /// 2 = full, 1 = compact, 0 = minimal.
  final int density;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    final color = slice.onColor;
    final hasAmount = slice.amountLabel.isNotEmpty;
    final semanticsLabel = [
      slice.label,
      if (hasAmount) slice.amountLabel,
      '$percent percent',
    ].join(', ');
    return IgnorePointer(
      child: Semantics(
        label: semanticsLabel,
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: SizedBox(
            width: 96,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (slice.icon != null)
                  Icon(slice.icon, color: color, size: 20),
                if (density >= 1)
                  Text(
                    slice.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (hasAmount)
                  Text(
                      slice.amountLabel,
                      style: TextStyle(
                        color: color,
                        fontSize: density == 2 ? 16 : 13,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [ui.FontFeature.tabularFigures()],
                      ),
                    ),
                if (density >= 1 && showPercent)
                  Text(
                    '($percent%)',
                    style: TextStyle(color: color, fontSize: 10),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
