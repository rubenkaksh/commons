import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/src/widgets/dotted_divider.dart';

void main() {
  // Loose constraints (Center) so the widget's own SizedBox decides the
  // rendered size — a tight parent (e.g. a Scaffold body) would force the
  // height/width and mask a sizing bug.
  Future<void> pumpDivider(
    WidgetTester tester, {
    Widget child = const DottedDivider(),
  }) async {
    await tester.pumpWidget(MaterialApp(home: Center(child: child)));
    await tester.pump();
  }

  // The single CustomPaint the widget owns.
  Finder customPaintOf(WidgetTester tester) => find.descendant(
    of: find.byType(DottedDivider),
    matching: find.byType(CustomPaint),
  );

  // Reads the painter back from the render tree so tests can assert on the
  // colour the widget resolved from the theme.
  DottedDividerPainter painterOf(WidgetTester tester) {
    final CustomPaint customPaint = tester.widget<CustomPaint>(
      customPaintOf(tester),
    );
    final CustomPainter? painter = customPaint.painter;
    if (painter is DottedDividerPainter) {
      return painter;
    }
    throw StateError(
      'DottedDivider must paint with DottedDividerPainter, got $painter',
    );
  }

  // Theme the widget actually renders against, so colour assertions compare
  // against the tree's own ColorScheme instead of a hand-built one.
  ThemeData themeOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(DottedDivider)));

  group('DottedDivider defaults', () {
    test('match the documented API', () {
      const DottedDivider divider = DottedDivider();
      expect(divider.axis, Axis.horizontal);
      expect(divider.thickness, 1.5);
      expect(divider.dashLength, 4);
      expect(divider.gap, 3);
      expect(divider.color, isNull, reason: 'colour must come from the theme');
    });
  });

  group('DottedDivider sizing', () {
    testWidgets('renders horizontally with height == thickness', (
      WidgetTester tester,
    ) async {
      await pumpDivider(tester);

      final Size size = tester.getSize(find.byType(DottedDivider));
      expect(size.height, 1.5);
      expect(
        size.width,
        tester.getSize(find.byType(Center)).width,
        reason: 'a horizontal divider spans the width it is given',
      );
      expect(painterOf(tester).axis, Axis.horizontal);
    });

    testWidgets('honours a custom thickness horizontally', (
      WidgetTester tester,
    ) async {
      await pumpDivider(tester, child: const DottedDivider(thickness: 3));

      expect(tester.getSize(find.byType(DottedDivider)).height, 3);
    });

    testWidgets('vertical axis gives width == thickness inside a 100-tall '
        'SizedBox', (WidgetTester tester) async {
      await pumpDivider(
        tester,
        child: const SizedBox(
          height: 100,
          child: DottedDivider(axis: Axis.vertical),
        ),
      );

      final Size size = tester.getSize(find.byType(DottedDivider));
      expect(size.width, 1.5, reason: 'cross axis is exactly the thickness');
      expect(size.height, 100, reason: 'fills the height it is given');
      expect(painterOf(tester).axis, Axis.vertical);
    });
  });

  group('DottedDivider colour', () {
    testWidgets('defaults to the theme colourScheme.outlineVariant', (
      WidgetTester tester,
    ) async {
      await pumpDivider(tester);

      expect(customPaintOf(tester), findsOneWidget);
      expect(
        painterOf(tester).color,
        themeOf(tester).colorScheme.outlineVariant,
      );
    });

    testWidgets('resolves from an overridden theme, not a baked-in colour', (
      WidgetTester tester,
    ) async {
      final ThemeData theme = ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light().copyWith(
          outlineVariant: const Color(0xFFABCDEF),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Center(child: DottedDivider()),
        ),
      );
      await tester.pump();

      expect(painterOf(tester).color, const Color(0xFFABCDEF));
    });

    testWidgets('an explicit colour wins over the theme', (
      WidgetTester tester,
    ) async {
      await pumpDivider(
        tester,
        child: const DottedDivider(color: Color(0xFF123456)),
      );

      expect(painterOf(tester).color, const Color(0xFF123456));
    });
  });

  group('DottedDivider painter', () {
    testWidgets('mirrors the widget parameters', (WidgetTester tester) async {
      await pumpDivider(
        tester,
        child: const DottedDivider(
          axis: Axis.vertical,
          thickness: 2,
          dashLength: 6,
          gap: 5,
          color: Color(0xFF0F0F0F),
        ),
      );

      final DottedDividerPainter painter = painterOf(tester);
      expect(painter.axis, Axis.vertical);
      expect(painter.thickness, 2);
      expect(painter.dashLength, 6);
      expect(painter.gap, 5);
      expect(painter.color, const Color(0xFF0F0F0F));
    });

    test('shouldRepaint is false when nothing changed', () {
      const DottedDividerPainter base = DottedDividerPainter(
        color: Color(0xFF112233),
        axis: Axis.horizontal,
        thickness: 1.5,
        dashLength: 4,
        gap: 3,
      );
      const DottedDividerPainter same = DottedDividerPainter(
        color: Color(0xFF112233),
        axis: Axis.horizontal,
        thickness: 1.5,
        dashLength: 4,
        gap: 3,
      );

      expect(base.shouldRepaint(same), isFalse);
    });

    test('shouldRepaint is true when any field changes', () {
      const DottedDividerPainter base = DottedDividerPainter(
        color: Color(0xFF112233),
        axis: Axis.horizontal,
        thickness: 1.5,
        dashLength: 4,
        gap: 3,
      );

      const DottedDividerPainter recoloured = DottedDividerPainter(
        color: Color(0xFF445566),
        axis: Axis.horizontal,
        thickness: 1.5,
        dashLength: 4,
        gap: 3,
      );
      const DottedDividerPainter rotated = DottedDividerPainter(
        color: Color(0xFF112233),
        axis: Axis.vertical,
        thickness: 1.5,
        dashLength: 4,
        gap: 3,
      );
      const DottedDividerPainter thicker = DottedDividerPainter(
        color: Color(0xFF112233),
        axis: Axis.horizontal,
        thickness: 2,
        dashLength: 4,
        gap: 3,
      );
      const DottedDividerPainter longerDash = DottedDividerPainter(
        color: Color(0xFF112233),
        axis: Axis.horizontal,
        thickness: 1.5,
        dashLength: 8,
        gap: 3,
      );
      const DottedDividerPainter widerGap = DottedDividerPainter(
        color: Color(0xFF112233),
        axis: Axis.horizontal,
        thickness: 1.5,
        dashLength: 4,
        gap: 6,
      );

      expect(base.shouldRepaint(recoloured), isTrue, reason: 'colour');
      expect(base.shouldRepaint(rotated), isTrue, reason: 'axis');
      expect(base.shouldRepaint(thicker), isTrue, reason: 'thickness');
      expect(base.shouldRepaint(longerDash), isTrue, reason: 'dashLength');
      expect(base.shouldRepaint(widerGap), isTrue, reason: 'gap');
    });

    testWidgets('draws with the CustomPaint, no ListView', (
      WidgetTester tester,
    ) async {
      await pumpDivider(tester);

      // Scoped to the widget: MaterialApp/Navigator paint their own
      // CustomPaints, so a global finder would over-count.
      expect(customPaintOf(tester), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DottedDivider),
          matching: find.byType(ScrollView),
        ),
        findsNothing,
        reason: 'the reference ListView approach must not come back',
      );
    });

    testWidgets('paints dashes at dashLength + gap intervals', (
      WidgetTester tester,
    ) async {
      await pumpDivider(
        tester,
        child: const SizedBox(
          width: 20,
          child: DottedDivider(
            dashLength: 4,
            gap: 3,
            color: Color(0xFF000000),
          ),
        ),
      );

      // paint() centres the stroke on the cross axis: thickness / 2 = 0.75.
      // Dashes start at 0, 7, 14; a fourth at 21 would exceed the width 20
      // and is not drawn.
      expect(
        find.byType(DottedDivider),
        paints
          ..line(p1: const Offset(0, 0.75), p2: const Offset(4, 0.75))
          ..line(p1: const Offset(7, 0.75), p2: const Offset(11, 0.75))
          ..line(p1: const Offset(14, 0.75), p2: const Offset(18, 0.75)),
      );
    });

    testWidgets('paints vertical dashes at dashLength + gap intervals', (
      WidgetTester tester,
    ) async {
      await pumpDivider(
        tester,
        child: const SizedBox(
          height: 20,
          child: DottedDivider(
            axis: Axis.vertical,
            dashLength: 4,
            gap: 3,
            color: Color(0xFF000000),
          ),
        ),
      );

      // Vertical mirror: the stroke sits at x = thickness / 2 = 0.75 and the
      // dashes step down 0, 7, 14 within the height 20.
      expect(
        find.byType(DottedDivider),
        paints
          ..line(p1: const Offset(0.75, 0), p2: const Offset(0.75, 4))
          ..line(p1: const Offset(0.75, 7), p2: const Offset(0.75, 11))
          ..line(p1: const Offset(0.75, 14), p2: const Offset(0.75, 18)),
      );
    });
  });
}
