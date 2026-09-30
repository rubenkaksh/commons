import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/src/widgets/buttons.dart';

void main() {
  // pump() rather than pumpAndSettle() while a CircularProgressIndicator is on
  // screen: the spinner animates forever, so pumpAndSettle would time out.
  Future<void> pumpButton(WidgetTester tester, Widget button) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: button))),
    );
    await tester.pump();
  }

  // Shared tap counter for the idle-button tests.
  int taps = 0;
  setUp(() {
    taps = 0;
  });
  VoidCallback countingOnPressed() => () => taps++;

  const String label = 'Continue';

  group('AppFilledButton', () {
    testWidgets('isLoading: true shows a spinner, keeps the label, ignores taps', (
      WidgetTester tester,
    ) async {
      await pumpButton(
        tester,
        AppFilledButton(
          text: label,
          isLoading: true,
          onPressed: countingOnPressed(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(label), findsOneWidget);

      final FilledButton rendered = tester.widget<FilledButton>(
        find.byType(FilledButton),
      );
      expect(rendered.onPressed, isNull, reason: 'loading disables the button');

      await tester.tap(find.text(label));
      await tester.pump();
      expect(taps, 0, reason: 'a loading button must not fire onPressed');
    });

    testWidgets('isLoading: false fires onPressed on tap and shows no spinner', (
      WidgetTester tester,
    ) async {
      await pumpButton(
        tester,
        AppFilledButton(text: label, onPressed: countingOnPressed()),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text(label), findsOneWidget);

      await tester.tap(find.text(label));
      await tester.pump();
      expect(taps, 1);
    });
  });

  group('AppOutlinedButton', () {
    testWidgets('isLoading: true shows a spinner, keeps the label, ignores taps', (
      WidgetTester tester,
    ) async {
      await pumpButton(
        tester,
        AppOutlinedButton(
          text: label,
          isLoading: true,
          onPressed: countingOnPressed(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(label), findsOneWidget);

      final OutlinedButton rendered = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(rendered.onPressed, isNull, reason: 'loading disables the button');

      await tester.tap(find.text(label));
      await tester.pump();
      expect(taps, 0, reason: 'a loading button must not fire onPressed');
    });

    testWidgets('isLoading: false fires onPressed on tap and shows no spinner', (
      WidgetTester tester,
    ) async {
      await pumpButton(
        tester,
        AppOutlinedButton(text: label, onPressed: countingOnPressed()),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text(label), findsOneWidget);

      await tester.tap(find.text(label));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('with an icon renders the icon and no spinner', (
      WidgetTester tester,
    ) async {
      await pumpButton(
        tester,
        AppOutlinedButton(
          text: label,
          icon: const Icon(Icons.rocket_launch),
          onPressed: countingOnPressed(),
        ),
      );

      expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
      expect(find.text(label), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('loading replaces the icon with the spinner', (
      WidgetTester tester,
    ) async {
      await pumpButton(
        tester,
        AppOutlinedButton(
          text: label,
          icon: const Icon(Icons.rocket_launch),
          isLoading: true,
          onPressed: countingOnPressed(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.rocket_launch), findsNothing);
      expect(find.text(label), findsOneWidget);
    });
  });

  group('GhostButton', () {
    testWidgets('isLoading: true shows a spinner, keeps the label, ignores taps', (
      WidgetTester tester,
    ) async {
      await pumpButton(
        tester,
        GhostButton(text: label, isLoading: true, onPressed: countingOnPressed()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(label), findsOneWidget);

      final TextButton rendered = tester.widget<TextButton>(
        find.byType(TextButton),
      );
      expect(rendered.onPressed, isNull, reason: 'loading disables the button');

      await tester.tap(find.text(label));
      await tester.pump();
      expect(taps, 0, reason: 'a loading button must not fire onPressed');
    });

    testWidgets('isLoading: false fires onPressed on tap and shows no spinner', (
      WidgetTester tester,
    ) async {
      await pumpButton(
        tester,
        GhostButton(text: label, onPressed: countingOnPressed()),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text(label), findsOneWidget);

      await tester.tap(find.text(label));
      await tester.pump();
      expect(taps, 1);
    });
  });
}
