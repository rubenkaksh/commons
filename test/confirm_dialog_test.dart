import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/src/l10n/commons_strings.dart';
import 'package:commons/src/widgets/confirm_dialog.dart';

/// Overrides only [cancel] so the scope-fallback test can prove the dialog
/// reads the caller's [CommonsStringsScope] instead of baking in English.
class _German extends CommonsStrings {
  const _German();

  @override
  String get cancel => 'Abbrechen';
}

/// Pumps a [MaterialApp] whose home is a button that opens the confirm dialog
/// with the given arguments. When [onResult] is given the pending future is
/// handed to it, so the test can assert on it after driving the dialog.
/// [theme] is applied to the [MaterialApp] so style assertions can compare
/// against a known [ColorScheme].
Future<void> _openDialog(
  WidgetTester tester, {
  void Function(Future<bool> result)? onResult,
  CommonsStrings? strings,
  String? message,
  String? cancelLabel,
  bool destructive = false,
  Widget? icon,
  ThemeData? theme,
}) async {
  final Widget body = Scaffold(
    body: Center(
      child: Builder(
        builder: (BuildContext context) => ElevatedButton(
          onPressed: () {
            final Future<bool> future = showConfirmDialog(
              context,
              title: 'Delete file?',
              message: message,
              confirmLabel: 'Delete',
              cancelLabel: cancelLabel,
              destructive: destructive,
              icon: icon,
            );
            onResult?.call(future);
          },
          child: const Text('Open'),
        ),
      ),
    ),
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: strings == null
          ? body
          : CommonsStringsScope(strings: strings, child: body),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  group('showConfirmDialog', () {
    testWidgets('confirm action completes the future with true',
        (WidgetTester tester) async {
      late Future<bool> result;
      await _openDialog(
        tester,
        onResult: (Future<bool> r) => result = r,
        message: 'This cannot be undone.',
      );

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Delete file?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(await result, isTrue);
    });

    testWidgets('cancel action completes the future with false',
        (WidgetTester tester) async {
      late Future<bool> result;
      await _openDialog(
        tester,
        onResult: (Future<bool> r) => result = r,
        message: 'This cannot be undone.',
      );

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(await result, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tapping the barrier completes the future with false',
        (WidgetTester tester) async {
      late Future<bool> result;
      await _openDialog(tester, onResult: (Future<bool> r) => result = r);

      // Well outside the centred dialog, on the modal barrier.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(await result, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('cancel label defaults to CommonsStrings "Cancel"',
        (WidgetTester tester) async {
      await _openDialog(tester);

      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Abbrechen'), findsNothing);
    });

    testWidgets('cancel label comes from a CommonsStringsScope override',
        (WidgetTester tester) async {
      await _openDialog(tester, strings: const _German());

      expect(find.widgetWithText(TextButton, 'Abbrechen'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsNothing);
    });

    testWidgets('an explicit cancelLabel wins over the scope default',
        (WidgetTester tester) async {
      await _openDialog(
        tester,
        strings: const _German(),
        cancelLabel: 'Dismiss',
      );

      expect(find.widgetWithText(TextButton, 'Dismiss'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Abbrechen'), findsNothing);
    });

    testWidgets('message null renders no content body',
        (WidgetTester tester) async {
      await _openDialog(tester, message: null);

      final AlertDialog dialog =
          tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(dialog.content, isNull);
      expect(find.text('This cannot be undone.'), findsNothing);
      // The dialog still renders its title and both actions.
      expect(find.text('Delete file?'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Delete'), findsOneWidget);
    });

    testWidgets('destructive styles the confirm button with the error colours',
        (WidgetTester tester) async {
      final ThemeData theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      await _openDialog(tester, destructive: true, theme: theme);

      final FilledButton b =
          tester.widget<FilledButton>(find.byType(FilledButton));
      final ColorScheme scheme =
          Theme.of(tester.element(find.byType(FilledButton))).colorScheme;
      expect(b.style?.backgroundColor?.resolve(<WidgetState>{}), scheme.error);
      expect(b.style?.foregroundColor?.resolve(<WidgetState>{}), scheme.onError);

      // Dismiss, then reopen without `destructive` under the same theme: the
      // implementation passes `style: null`, so no error colours are applied.
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      await _openDialog(tester, theme: theme);

      final FilledButton plain =
          tester.widget<FilledButton>(find.byType(FilledButton));
      expect(plain.style, isNull);
    });

    testWidgets('renders the optional icon', (WidgetTester tester) async {
      await _openDialog(tester, icon: const Icon(Icons.warning_amber));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });
  });
}
