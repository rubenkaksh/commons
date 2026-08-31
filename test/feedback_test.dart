import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:commons/commons.dart';

void main() {
  // Skeletonizer is an abstract class instantiated via a private factory
  // (const Skeletonizer(...) = _Skeletonizer), so find.byType(Skeletonizer)
  // matches nothing — match by predicate instead.
  Finder skeleton() => find.byWidgetPredicate((Widget w) => w is Skeletonizer);

  testWidgets('LoadingView renders a skeleton instead of the old spinner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingView())),
    );
    await tester.pump();

    expect(
      skeleton(),
      findsOneWidget,
      reason: 'loading must be skeletonized, not a spinner',
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('LoadingView keeps the message below the skeleton', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingView(message: 'Loading…'))),
    );
    await tester.pump();

    expect(skeleton(), findsOneWidget);
    expect(find.text('Loading…'), findsOneWidget);
  });
}
