import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/src/widgets/filter_chip_group.dart';

void main() {
  // The group only needs a bounded area; Scaffold body gives Wrap a width.
  Future<void> pumpGroup(
    WidgetTester tester,
    FilterChipGroup<String> group,
  ) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: group)));
    await tester.pump();
  }

  FilterChipGroup<String> groupWith({
    required List<String> options,
    required Set<String> selected,
    required ValueChanged<Set<String>> onChanged,
    bool multiSelect = true,
    bool allowEmpty = true,
    double spacing = 8,
  }) => FilterChipGroup<String>(
    options: options,
    selected: selected,
    onChanged: onChanged,
    labelBuilder: (String option) => 'label-$option',
    multiSelect: multiSelect,
    allowEmpty: allowEmpty,
    spacing: spacing,
  );

  FilterChip chipFor(WidgetTester tester, String option) =>
      tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'label-$option'),
      );

  group('FilterChipGroup rendering', () {
    testWidgets('renders one FilterChip per option with labelBuilder text', (
      WidgetTester tester,
    ) async {
      await pumpGroup(
        tester,
        groupWith(
          options: <String>['a', 'b', 'c'],
          selected: <String>{},
          onChanged: (_) {},
        ),
      );

      expect(find.byType(FilterChip), findsNWidgets(3));
      expect(find.text('label-a'), findsOneWidget);
      expect(find.text('label-b'), findsOneWidget);
      expect(find.text('label-c'), findsOneWidget);
    });

    testWidgets('marks selected chips with selected == true', (
      WidgetTester tester,
    ) async {
      await pumpGroup(
        tester,
        groupWith(
          options: <String>['a', 'b'],
          selected: <String>{'b'},
          onChanged: (_) {},
        ),
      );

      expect(chipFor(tester, 'a').selected, isFalse);
      expect(chipFor(tester, 'b').selected, isTrue);
    });
  });

  group('FilterChipGroup multi-select', () {
    testWidgets('tapping an unselected chip adds it to the set', (
      WidgetTester tester,
    ) async {
      Set<String>? received;
      await pumpGroup(
        tester,
        groupWith(
          options: <String>['a', 'b'],
          selected: <String>{'a'},
          onChanged: (Set<String> next) => received = next,
        ),
      );

      await tester.tap(find.widgetWithText(FilterChip, 'label-b'));
      await tester.pump();

      expect(received, <String>{'a', 'b'});
    });

    testWidgets('tapping a selected chip removes it', (
      WidgetTester tester,
    ) async {
      Set<String>? received;
      await pumpGroup(
        tester,
        groupWith(
          options: <String>['a', 'b'],
          selected: <String>{'a', 'b'},
          onChanged: (Set<String> next) => received = next,
        ),
      );

      await tester.tap(find.widgetWithText(FilterChip, 'label-a'));
      await tester.pump();

      expect(received, <String>{'b'});
    });

    testWidgets('allowEmpty false blocks removing the last selected', (
      WidgetTester tester,
    ) async {
      final Set<String> selected = <String>{'a'};
      Set<String>? received;
      await pumpGroup(
        tester,
        groupWith(
          options: <String>['a', 'b'],
          selected: selected,
          allowEmpty: false,
          onChanged: (Set<String> next) => received = next,
        ),
      );

      await tester.tap(find.widgetWithText(FilterChip, 'label-a'));
      await tester.pump();

      expect(received, <String>{'a'}, reason: 'must report the unchanged set');
    });

    testWidgets('allowEmpty false still allows removing a non-last item', (
      WidgetTester tester,
    ) async {
      Set<String>? received;
      await pumpGroup(
        tester,
        groupWith(
          options: <String>['a', 'b'],
          selected: <String>{'a', 'b'},
          allowEmpty: false,
          onChanged: (Set<String> next) => received = next,
        ),
      );

      await tester.tap(find.widgetWithText(FilterChip, 'label-a'));
      await tester.pump();

      expect(received, <String>{'b'});
    });
  });

  group('FilterChipGroup single-select', () {
    testWidgets('tapping an option selects only that option', (
      WidgetTester tester,
    ) async {
      Set<String>? received;
      await pumpGroup(
        tester,
        groupWith(
          options: <String>['a', 'b', 'c'],
          selected: <String>{'a'},
          multiSelect: false,
          onChanged: (Set<String> next) => received = next,
        ),
      );

      await tester.tap(find.widgetWithText(FilterChip, 'label-c'));
      await tester.pump();

      expect(received, <String>{'c'});
    });

    testWidgets('tapping the selected option clears when allowEmpty', (
      WidgetTester tester,
    ) async {
      Set<String>? received;
      await pumpGroup(
        tester,
        groupWith(
          options: <String>['a', 'b'],
          selected: <String>{'a'},
          multiSelect: false,
          allowEmpty: true,
          onChanged: (Set<String> next) => received = next,
        ),
      );

      await tester.tap(find.widgetWithText(FilterChip, 'label-a'));
      await tester.pump();

      expect(received, isEmpty);
    });

    testWidgets('tapping the selected option keeps it when !allowEmpty', (
      WidgetTester tester,
    ) async {
      final Set<String> selected = <String>{'a'};
      Set<String>? received;
      await pumpGroup(
        tester,
        groupWith(
          options: <String>['a', 'b'],
          selected: selected,
          multiSelect: false,
          allowEmpty: false,
          onChanged: (Set<String> next) => received = next,
        ),
      );

      await tester.tap(find.widgetWithText(FilterChip, 'label-a'));
      await tester.pump();

      expect(received, <String>{'a'});
    });
  });

  group('FilterChipGroup input set immutability', () {
    testWidgets('never mutates the incoming selected set', (
      WidgetTester tester,
    ) async {
      final Set<String> selected = Set<String>.unmodifiable(<String>{'a'});
      await pumpGroup(
        tester,
        groupWith(
          options: <String>['a', 'b'],
          selected: selected,
          onChanged: (_) {},
        ),
      );

      // Tapping the selected chip computes {a, b} / {} via copies; the
      // unmodifiable original must survive both directions untouched.
      await tester.tap(find.widgetWithText(FilterChip, 'label-b'));
      await tester.pump();
      expect(selected, <String>{'a'});

      await tester.tap(find.widgetWithText(FilterChip, 'label-a'));
      await tester.pump();
      expect(selected, <String>{'a'});
    });
  });
}
