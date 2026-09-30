import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/src/widgets/avatar_stack.dart';

void main() {
  // Pumps AvatarStack inside a Center: Align hands out loose constraints, so
  // the widget's own SizedBox decides the rendered size (a Scaffold body or a
  // tight parent could force it and hide a sizing bug).
  Future<void> pumpStack(
    WidgetTester tester, {
    required List<Widget> avatars,
    double size = 32,
    double overlap = 0.3,
    int? maxVisible,
    double borderWidth = 2,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AvatarStack(
            avatars: avatars,
            size: size,
            overlap: overlap,
            maxVisible: maxVisible,
            borderWidth: borderWidth,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  // One ClipOval per slot: avatars plus the optional "+N" circle.
  Finder slotsOf(WidgetTester tester) => find.descendant(
    of: find.byType(AvatarStack),
    matching: find.byType(ClipOval),
  );

  Finder positionsOf(WidgetTester tester) => find.descendant(
    of: find.byType(AvatarStack),
    matching: find.byType(Positioned),
  );

  Finder circlesOf(WidgetTester tester) => find.descendant(
    of: find.byType(AvatarStack),
    matching: find.byType(Container),
  );

  // Theme the widget actually renders against, so colour assertions compare
  // against the tree's own ColorScheme instead of a hand-built one.
  ThemeData themeOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(AvatarStack)));

  List<Widget> many(int count) =>
      List<Widget>.generate(count, (int i) => Text('a$i'));

  test('defaults match the documented API', () {
    const AvatarStack stack = AvatarStack(avatars: <Widget>[]);
    expect(stack.size, 32);
    expect(stack.overlap, 0.3);
    expect(stack.maxVisible, isNull);
    expect(stack.borderWidth, 2);
  });

  test('overlap must satisfy 0 <= overlap < 1', () {
    expect(
      () => AvatarStack(avatars: const <Widget>[], overlap: 1),
      throwsA(isA<AssertionError>()),
      reason: 'overlap of exactly 1 would stack every avatar on top of one',
    );
    expect(
      () => AvatarStack(avatars: const <Widget>[], overlap: -0.1),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => AvatarStack(avatars: const <Widget>[], overlap: 0),
      returnsNormally,
    );
    expect(
      () => AvatarStack(avatars: const <Widget>[], overlap: 0.99),
      returnsNormally,
    );
  });

  testWidgets('an empty avatar list renders zero size', (
    WidgetTester tester,
  ) async {
    await pumpStack(tester, avatars: const <Widget>[]);

    expect(tester.getSize(find.byType(AvatarStack)), Size.zero);
    expect(slotsOf(tester), findsNothing);
    expect(positionsOf(tester), findsNothing);
  });

  testWidgets('three avatars are 80 wide: size + (count-1) * size * (1-overlap)', (
    WidgetTester tester,
  ) async {
    await pumpStack(tester, avatars: many(3), size: 32, overlap: 0.25);

    final Size actual = tester.getSize(find.byType(AvatarStack));
    expect(actual.width, 80, reason: '32 + 2 * (32 * 0.75) = 80');
    expect(actual.height, 32);

    // The Stack is only sized because of the wrapping SizedBox.
    expect(
      find.descendant(of: find.byType(AvatarStack), matching: find.byType(Stack)),
      findsOneWidget,
    );

    final List<Positioned> placed = tester
        .widgetList<Positioned>(positionsOf(tester))
        .toList();
    expect(placed, hasLength(3));
    expect(
      placed.map((Positioned p) => p.left).toList(),
      <double>[0.0, 24.0, 48.0],
    );
    expect(
      placed.every(
        (Positioned p) => p.top == 0 && p.width == 32 && p.height == 32,
      ),
      isTrue,
      reason: 'each slot is a full-size square stepped by size * (1 - overlap)',
    );
  });

  testWidgets('every avatar is clipped to a circle of diameter size', (
    WidgetTester tester,
  ) async {
    await pumpStack(tester, avatars: many(3), size: 48, overlap: 0.25);

    final Finder clips = slotsOf(tester);
    expect(clips, findsNWidgets(3));
    for (final ClipOval clip in tester.widgetList<ClipOval>(clips)) {
      final Widget? child = clip.child;
      expect(child, isA<SizedBox>(), reason: 'clip wraps a sized circle');
      if (child case final SizedBox circle) {
        expect(circle.width, 48);
        expect(circle.height, 48);
      }
    }
    expect(find.text('a0'), findsOneWidget);
    expect(find.text('a1'), findsOneWidget);
    expect(find.text('a2'), findsOneWidget);
  });

  testWidgets('slots carry a surface-coloured ring of borderWidth', (
    WidgetTester tester,
  ) async {
    await pumpStack(tester, avatars: many(3), borderWidth: 4);
    final ThemeData theme = themeOf(tester);

    final Finder circles = circlesOf(tester);
    expect(circles, findsNWidgets(3));
    for (final Container slot in tester.widgetList<Container>(circles)) {
      if (slot.decoration case final BoxDecoration ring) {
        expect(ring.shape, BoxShape.circle);
        expect(ring.border?.top.width, 4);
        expect(ring.border?.top.color, theme.colorScheme.surface);
        expect(ring.color, isNull, reason: 'avatars keep their own background');
      } else {
        fail('slot decoration must be a BoxDecoration, was ${slot.decoration}');
      }
    }
  });

  testWidgets('maxVisible: 2 with 5 avatars shows two avatars and "+3"', (
    WidgetTester tester,
  ) async {
    await pumpStack(tester, avatars: many(5), maxVisible: 2);

    expect(find.text('a0'), findsOneWidget);
    expect(find.text('a1'), findsOneWidget);
    expect(find.text('a2'), findsNothing);
    expect(find.text('a3'), findsNothing);
    expect(find.text('a4'), findsNothing);
    expect(find.text('+3'), findsOneWidget);
    expect(slotsOf(tester), findsNWidgets(3), reason: '2 avatars + "+N"');
  });

  testWidgets('the "+N" circle uses secondaryContainer, onSecondaryContainer and labelSmall', (
    WidgetTester tester,
  ) async {
    await pumpStack(tester, avatars: many(5), maxVisible: 2);
    final ThemeData theme = themeOf(tester);

    final Text overflow = tester.widget<Text>(find.text('+3'));
    expect(overflow.style, isNotNull);
    expect(overflow.style?.color, theme.colorScheme.onSecondaryContainer);
    expect(overflow.style?.fontSize, theme.textTheme.labelSmall?.fontSize);

    final List<Container> circles = tester
        .widgetList<Container>(circlesOf(tester))
        .toList();
    expect(circles, hasLength(3));
    if (circles.last.decoration case final BoxDecoration ring) {
      expect(ring.color, theme.colorScheme.secondaryContainer);
    } else {
      fail('overflow slot must be decorated with a BoxDecoration');
    }
  });

  testWidgets('maxVisible at the count keeps every avatar and adds no circle', (
    WidgetTester tester,
  ) async {
    await pumpStack(tester, avatars: many(3), maxVisible: 3);

    expect(find.text('a0'), findsOneWidget);
    expect(find.text('a1'), findsOneWidget);
    expect(find.text('a2'), findsOneWidget);
    expect(slotsOf(tester), findsNWidgets(3));

    final Iterable<String?> shown = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(AvatarStack),
            matching: find.byType(Text),
          ),
        )
        .map((Text t) => t.data);
    expect(
      shown.where((String? s) => s != null && s.startsWith('+')),
      isEmpty,
      reason: 'nothing hidden, so no "+N" indicator',
    );
  });
}
