import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/src/widgets/section_header.dart';

void main() {
  // A whole app per pump: the header lays out inside a Scaffold body so the
  // Row gets bounded width from the screen (its Spacer needs it).
  Future<void> pumpHeader(
    WidgetTester tester,
    SectionHeader header,
  ) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: header)));
    await tester.pump();
  }

  SectionHeader headerWith({
    required String title,
    Widget? leadingIcon,
    VoidCallback? onTap,
    Widget? action,
  }) => SectionHeader(
    title: title,
    leadingIcon: leadingIcon,
    onTap: onTap,
    action: action,
  );

  group('SectionHeader rendering', () {
    testWidgets('renders the title', (WidgetTester tester) async {
      await pumpHeader(tester, headerWith(title: 'Settings'));

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows the leadingIcon when given', (
      WidgetTester tester,
    ) async {
      await pumpHeader(
        tester,
        headerWith(
          title: 'Profile',
          leadingIcon: const Icon(Icons.person, key: Key('leading')),
        ),
      );

      expect(find.byKey(const Key('leading')), findsOneWidget);
      // Rendered inside the header, before the title.
      expect(
        find.descendant(
          of: find.byType(SectionHeader),
          matching: find.byKey(const Key('leading')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('omits the leadingIcon when not given', (
      WidgetTester tester,
    ) async {
      await pumpHeader(tester, headerWith(title: 'Account'));

      expect(find.byType(Icon), findsNothing);
    });
  });

  group('SectionHeader onTap chevron', () {
    testWidgets('shows a chevron IconButton and calls onTap when tapped', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await pumpHeader(
        tester,
        headerWith(title: 'Recent', onTap: () => tapped = true),
      );

      final Finder chevron = find.byIcon(Icons.chevron_right);
      expect(chevron, findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);

      await tester.tap(chevron);
      await tester.pump();

      expect(tapped, isTrue, reason: 'tapping the chevron must fire onTap');
    });

    testWidgets('shows no chevron when neither onTap nor action is given', (
      WidgetTester tester,
    ) async {
      await pumpHeader(tester, headerWith(title: 'Static'));

      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byType(IconButton), findsNothing);
    });
  });

  group('SectionHeader action slot', () {
    testWidgets('renders the action widget instead of the chevron', (
      WidgetTester tester,
    ) async {
      await pumpHeader(
        tester,
        headerWith(title: 'Friends', action: const Text('See all')),
      );

      expect(find.text('See all'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('replaces the chevron even when onTap is also set', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await pumpHeader(
        tester,
        headerWith(
          title: 'Friends',
          onTap: () => tapped = true,
          action: TextButton(
            onPressed: () => tapped = true,
            child: const Text('See all'),
          ),
        ),
      );

      // The action wins: no chevron, no IconButton in the trailing slot.
      expect(find.text('See all'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byType(IconButton), findsNothing);

      // The action itself stays interactive.
      await tester.tap(find.text('See all'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders the action at the trailing end, after the Spacer', (
      WidgetTester tester,
    ) async {
      await pumpHeader(
        tester,
        headerWith(title: 'Friends', action: const Text('See all')),
      );

      final Rect headerRect = tester.getRect(find.byType(SectionHeader));
      final Rect actionRect = tester.getRect(find.text('See all'));

      // Trailing = flush to the header's right edge, never beside the title.
      expect(actionRect.right, closeTo(headerRect.right, 0.01));
      expect(
        actionRect.left,
        greaterThan(headerRect.center.dx),
        reason: 'action belongs in the trailing half of the row',
      );
    });
  });
}
