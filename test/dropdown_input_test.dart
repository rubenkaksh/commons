import 'package:flutter/material.dart' as m;
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/commons.dart';

void main() {
  Future<void> pumpDropdown(
    WidgetTester tester, {
    String? value,
    List<(String, String)> items = const <(String, String)>[
      ('a', 'Alpha'),
      ('b', 'Beta'),
    ],
    m.ValueChanged<String?>? onChanged,
  }) {
    return tester.pumpWidget(
      m.MaterialApp(
        home: m.Scaffold(
          body: DropdownInput<String>(
            label: 'Pick one',
            hint: 'Choose an option',
            value: value,
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  testWidgets('renders the label and hint', (WidgetTester tester) async {
    await pumpDropdown(tester);
    expect(find.text('Pick one'), findsOneWidget);
    expect(find.text('Choose an option'), findsOneWidget);
  });

  testWidgets('shows the selected value', (WidgetTester tester) async {
    await pumpDropdown(tester, value: 'b');
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('opens the menu and fires onChanged with the picked value', (
    WidgetTester tester,
  ) async {
    String? picked;
    await pumpDropdown(tester, onChanged: (String? v) => picked = v);

    await tester.tap(find.text('Pick one'));
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsWidgets);
    expect(find.text('Beta'), findsWidgets);

    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();
    expect(picked, 'b');
  });

  testWidgets('renders the error text when provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      m.MaterialApp(
        home: m.Scaffold(
          body: const DropdownInput<String>(
            label: 'Pick one',
            items: <(String, String)>[('a', 'Alpha')],
            error: 'Please choose',
          ),
        ),
      ),
    );
    expect(find.text('Please choose'), findsOneWidget);
  });

  testWidgets('disables the dropdown when enabled is false', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      m.MaterialApp(
        home: m.Scaffold(
          body: const DropdownInput<String>(
            label: 'Pick one',
            items: <(String, String)>[('a', 'Alpha')],
            enabled: false,
          ),
        ),
      ),
    );
    final m.DropdownButtonFormField<String> field =
        tester.widget<m.DropdownButtonFormField<String>>(
          find.byType(m.DropdownButtonFormField<String>),
        );
    expect(field.onChanged, isNull);
  });
}
