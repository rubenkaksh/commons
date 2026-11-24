import 'package:commons/src/charts/rose_chart.dart';
import 'package:commons/src/charts/rose_slice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';

List<RoseSlice<void>> _slices(int n) => [
      for (var i = 0; i < n; i++)
        RoseSlice<void>(
          id: 's$i',
          label: 'Stream $i',
          magnitude: (n - i) * 100.0,
          amountLabel: '\$${(n - i) * 100}',
          color: Colors.purple,
          onColor: Colors.white,
          icon: Icons.music_note,
        ),
    ];

Future<void> _pump(WidgetTester tester, List<RoseSlice<void>> slices) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RoseChart<void>(
          slices: slices,
          centerBuilder: (d) => Container(
            key: const Key('centre'),
            width: d,
            height: d,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders 10 slices with amounts and centre', (tester) async {
    final slices = _slices(10);
    await _pump(tester, slices);
    expect(tester.takeException(), isNull);
    for (final s in slices) {
      expect(find.text(s.amountLabel), findsWidgets);
    }
    expect(find.byKey(const Key('centre')), findsOneWidget);
  });

  testWidgets('15 slices show +4 more', (tester) async {
    await _pump(tester, _slices(15));
    expect(tester.takeException(), isNull);
    expect(find.text('+4 more'), findsWidgets);
  });

  testWidgets('zero-size constraints render without exception', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 0,
              height: 0,
              child: RoseChart<void>(slices: _slices(5)),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(PieChart), findsNothing);
  });

  testWidgets('empty slices list renders without exception', (tester) async {
    await _pump(tester, const []);
    expect(tester.takeException(), isNull);
  });

  testWidgets('single slice renders its amount', (tester) async {
    final slices = _slices(1);
    await _pump(tester, slices);
    expect(tester.takeException(), isNull);
    expect(find.text(slices.single.amountLabel), findsWidgets);
  });

  testWidgets('all-zero magnitudes render without exception', (tester) async {
    final slices = [
      for (var i = 0; i < 4; i++)
        RoseSlice<void>(
          id: 'z$i',
          label: 'Zero $i',
          magnitude: 0,
          amountLabel: r'$0',
          color: Colors.purple,
          onColor: Colors.white,
        ),
    ];
    await _pump(tester, slices);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long amount label wraps within the badge width',
      (tester) async {
    const long = '\$1,234,567,890,123';
    final base = _slices(10);
    final slices = [
      RoseSlice<void>(
        id: base.first.id,
        label: base.first.label,
        magnitude: base.first.magnitude,
        amountLabel: long,
        color: base.first.color,
        onColor: base.first.onColor,
        icon: base.first.icon,
      ),
      ...base.skip(1),
    ];
    await _pump(tester, slices);
    expect(tester.takeException(), isNull);
    expect(find.text(long), findsWidgets);
    final rect = tester.getRect(find.text(long).first);
    expect(rect.width, lessThanOrEqualTo(96.5));
  });

  testWidgets('merged more-slice has no empty segment in its semantics label',
      (tester) async {
    await _pump(tester, _slices(15));
    expect(tester.takeException(), isNull);
    // fl_chart 1.2.0 excludes badge semantics from the semantics tree
    // (RenderPieChart.visitChildrenForSemantics is empty), so the label is
    // checked on the Semantics widget itself.
    String labelOf(Widget w) =>
        w is Semantics ? (w.properties.label ?? '') : '';
    expect(
      find.byWidgetPredicate((w) => labelOf(w).contains(', ,')),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (w) => RegExp(r'^\+4 more, \d+ percent$').hasMatch(labelOf(w)),
      ),
      findsOneWidget,
    );
  });
}
