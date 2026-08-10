import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:commons/commons.dart';

void main() {
  group('FormBottomSheet', () {
    testWidgets('renders title and body', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Test Title',
            body: const Text('Test Body'),
            confirmLabel: 'Confirm',
            onConfirm: () {},
          ),
        ),
      ));
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Body'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            subtitle: 'Subtitle text',
            body: const SizedBox(),
            confirmLabel: 'OK',
            onConfirm: () {},
          ),
        ),
      ));
      expect(find.text('Subtitle text'), findsOneWidget);
    });

    testWidgets('does not render subtitle when null', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'OK',
            onConfirm: () {},
          ),
        ),
      ));
      expect(find.text('Subtitle text'), findsNothing);
    });

    testWidgets('confirm button disabled when confirmEnabled is false', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'Confirm',
            onConfirm: () {},
            confirmEnabled: false,
          ),
        ),
      ));
      final finder = find.widgetWithText(FilledButton, 'Confirm');
      expect(tester.widget<FilledButton>(finder).onPressed, isNull);
    });

    testWidgets('confirm button enabled when confirmEnabled is true', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'Confirm',
            onConfirm: () {},
            confirmEnabled: true,
          ),
        ),
      ));
      final finder = find.widgetWithText(FilledButton, 'Confirm');
      expect(tester.widget<FilledButton>(finder).onPressed, isNotNull);
    });

    testWidgets('cancel button calls onCancel when provided', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'Confirm',
            onConfirm: () {},
            onCancel: () => cancelled = true,
          ),
        ),
      ));
      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    });

    testWidgets('cancel button uses custom label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FormBottomSheet(
            title: 'Title',
            body: const SizedBox(),
            confirmLabel: 'OK',
            onConfirm: () {},
            cancelLabel: 'Close',
          ),
        ),
      ));
      expect(find.text('Close'), findsOneWidget);
    });
  });

  group('showFormBottomSheet (generic keyboard behavior)', () {
    testWidgets('focuses the first input on open', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showFormBottomSheet<void>(
                  context: context,
                  builder: (_) => FormBottomSheet(
                    title: 'Book',
                    body: TextInput(label: 'Name'),
                    confirmLabel: 'Confirm',
                    onConfirm: () {},
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final EditableText editable = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editable.focusNode.hasFocus, isTrue,
          reason: 'primary input must receive focus when the sheet opens');
    });

    testWidgets('insets bottom by keyboard height (pushes content up)', (
      tester,
    ) async {
      // Simulate an open keyboard. The engine clamps viewInsets to
      // viewPadding, so raise viewPadding alongside viewInsets.
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      tester.view.viewPadding = const FakeViewPadding(bottom: 300);
      addTearDown(() {
        tester.view.resetViewInsets();
        tester.view.resetViewPadding();
      });

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showFormBottomSheet<void>(
                  context: context,
                  builder: (_) => FormBottomSheet(
                    title: 'Book',
                    body: const SizedBox(height: 200),
                    confirmLabel: 'Confirm',
                    onConfirm: () {},
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Invariant: the sheet's bottom padding must equal exactly the keyboard
      // height the sheet context sees (however the platform reports it).
      final double keyboardHeight = MediaQuery.viewInsetsOf(
        tester.element(find.byType(FormBottomSheet)),
      ).bottom;
      expect(keyboardHeight, greaterThan(0),
          reason: 'test setup must simulate an open keyboard');

      final AnimatedPadding animatedPadding = tester.widget<AnimatedPadding>(
        find.byWidgetPredicate(
          (Widget w) =>
              w is AnimatedPadding &&
              w.padding.resolve(TextDirection.ltr).bottom > 0,
        ),
      );
      expect(animatedPadding.padding.resolve(TextDirection.ltr).bottom,
          keyboardHeight,
          reason: 'sheet must ride above the keyboard');
    });

    testWidgets('sizes to its content, not the full screen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showFormBottomSheet<void>(
                  context: context,
                  builder: (_) => FormBottomSheet(
                    title: 'Book',
                    body: const SizedBox(height: 200),
                    confirmLabel: 'Confirm',
                    onConfirm: () {},
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final double sheetHeight = tester.getSize(
        find.byType(FormBottomSheet),
      ).height;
      final double screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(sheetHeight, lessThan(screenHeight),
          reason: 'sheet must wrap its content, not expand to full screen');
      expect(sheetHeight, greaterThan(200),
          reason: 'sheet must fit the 200px body plus header and CTAs');
    });
  });
}
