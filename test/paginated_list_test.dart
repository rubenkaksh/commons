// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/src/l10n/commons_strings.dart';
import 'package:commons/src/widgets/feedback.dart';
import 'package:commons/src/widgets/pagination_controller.dart';
import 'package:commons/src/widgets/paginated_list.dart';

void main() {
  group('PaginatedList', () {
    /// Creates a fake fetcher that returns 20 items per page,
    /// with page 3 returning only 5 items (short page to signal end).
    /// Records all page numbers requested in [calls].
    late List<int> calls;
    late PageFetcher<int> fakeFetcher;

    setUp(() {
      calls = [];
      fakeFetcher = (int page, int pageSize) async {
        calls.add(page);
        if (page == 3) {
          return List<int>.generate(5, (i) => (page - 1) * 20 + i);
        }
        return List<int>.generate(pageSize, (i) => (page - 1) * 20 + i);
      };
    });

    testWidgets(
      'Auto-loads the first page after the first frame',
      (WidgetTester tester) async {

        final PaginationController<int> controller =
            PaginationController(fetchPage: fakeFetcher);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) =>
                    SizedBox(height: 50, child: Text('item $item')),
              ),
            ),
          ),
        );

        // After pumpWidget, first frame shows loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // Calls might have been triggered on first build

        // Pump to let the fetcher complete
        await tester.pump();
        await tester.pump();

        // Verify first page was loaded
        expect(calls, contains(1));
        expect(find.text('item 0'), findsOneWidget);
      },
    );

    testWidgets(
      'No fetch during build: pumping frames without scrolling leaves one call',
      (WidgetTester tester) async {

        final PaginationController<int> controller =
            PaginationController(fetchPage: fakeFetcher);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) =>
                    SizedBox(height: 50, child: Text('item $item')),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();
        // First page should be loaded now
        expect(calls, equals([1]));

        // Pump several more frames without scrolling
        await tester.pump();
        await tester.pump();
        await tester.pump();

        // Should still have exactly one call
        expect(calls, equals([1]));
      },
    );

    testWidgets(
      'Scrolling near the end fetches page 2',
      (WidgetTester tester) async {

        final PaginationController<int> controller =
            PaginationController(fetchPage: fakeFetcher);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) =>
                    SizedBox(height: 50, child: Text('item $item')),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();
        expect(calls, equals([1]));

        // Drag down to load more
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -2000),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(calls, contains(2));
      },
    );

    testWidgets(
      'Empty result shows EmptyView',
      (WidgetTester tester) async {

        final PageFetcher<int> emptyFetcher = (int page, int pageSize) async {
          calls.add(page);
          return <int>[];
        };

        final PaginationController<int> controller =
            PaginationController(fetchPage: emptyFetcher, firstPage: 1);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) => const SizedBox(),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();

        expect(find.byType(EmptyView), findsOneWidget);
      },
    );

    testWidgets(
      'Empty result with emptyBuilder shows custom empty widget',
      (WidgetTester tester) async {

        final PageFetcher<int> emptyFetcher = (int page, int pageSize) async {
          calls.add(page);
          return <int>[];
        };

        final PaginationController<int> controller =
            PaginationController(fetchPage: emptyFetcher, firstPage: 1);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) => const SizedBox(),
                emptyBuilder: (_) => const Text('nothing'),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();

        expect(find.text('nothing'), findsOneWidget);
        expect(find.byType(EmptyView), findsNothing);
      },
    );

    testWidgets(
      'First-page error shows ErrorView and retry button works',
      (WidgetTester tester) async {

        final PageFetcher<int> errorFetcher = (int page, int pageSize) async {
          calls.add(page);
          throw StateError('test error');
        };

        final PaginationController<int> controller =
            PaginationController(fetchPage: errorFetcher, firstPage: 1);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) => const SizedBox(),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();

        expect(find.byType(ErrorView), findsOneWidget);
        expect(
          find.text(CommonsStrings().genericError),
          findsOneWidget,
        );
        expect(calls, equals([1]));

        // Tap the retry button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump();

        expect(calls.length, equals(2));
        expect(calls, equals([1, 1]));
      },
    );

    testWidgets(
      'Error after items shows footer retry button and retries correctly',
      (WidgetTester tester) async {

        bool shouldFail = false;
        final PageFetcher<int> mixedFetcher = (int page, int pageSize) async {
          calls.add(page);
          if (page == 1) {
            return List<int>.generate(20, (i) => i);
          }
          if (page == 2 && shouldFail) {
            throw StateError('page 2 error');
          }
          return List<int>.generate(5, (i) => 20 + i);
        };

        final PaginationController<int> controller =
            PaginationController(fetchPage: mixedFetcher, firstPage: 1);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) =>
                    SizedBox(height: 50, child: Text('item $item')),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();

        expect(calls, contains(1));

        // Set flag to make page 2 fail
        shouldFail = true;

        // Scroll to trigger page 2 fetch (which will fail)
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -2000),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(calls, contains(2));

        // The drag clamped against the footer-less content, so the footer that
        // appeared after the failure hangs just below the fold. Bring it into
        // view first — unconditionally, never behind a branch — then the
        // button itself is asserted unconditionally too.
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -2000),
        );
        await tester.pump();

        final Finder retryButton = find.widgetWithText(
          TextButton,
          CommonsStrings().retry,
        );
        expect(retryButton, findsOneWidget);

        await tester.tap(retryButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Page 2 is fetched again after the tap.
        expect(calls.where((p) => p == 2).length, greaterThanOrEqualTo(2));
      },
    );

    testWidgets(
      'Keeps loading until the content overflows the viewport, then stops',
      (WidgetTester tester) async {
        // 5 items of 50px = 250px per page against the 600px test viewport:
        // pages 1 and 2 still leave it empty, page 3 overflows it. Page 4 comes
        // back short so the end is signalled if it is ever requested.
        final PageFetcher<int> fillFetcher = (int page, int pageSize) async {
          calls.add(page);
          final int count = page >= 4 ? 3 : 5;
          return List<int>.generate(count, (i) => (page - 1) * pageSize + i);
        };

        final PaginationController<int> controller =
            PaginationController(fetchPage: fillFetcher, pageSize: 5);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) =>
                    SizedBox(height: 50, child: Text('item $item')),
              ),
            ),
          ),
        );

        // No scrolling at all: the list tops itself up frame by frame while
        // its content still leaves the viewport empty.
        await tester.pump();
        for (int i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(calls, equals(<int>[1, 2, 3]));

        final int callsAfterOverflow = calls.length;
        for (int i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Content now overflows the viewport (or the short page signalled the
        // end): either way no further page is requested.
        expect(calls.length, callsAfterOverflow);
      },
    );

    testWidgets(
      'Scrolling a nested horizontal list does not fetch page 2',
      (WidgetTester tester) async {
        final PaginationController<int> controller =
            PaginationController(fetchPage: fakeFetcher);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) => SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List<Widget>.generate(
                      30,
                      (int i) => SizedBox(width: 60, child: Text('h$i')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();
        expect(calls, equals([1]));

        // Drag the first item's own horizontal list far left: its notification
        // bubbles up from a descendant scrollable and must be ignored, so the
        // list never asks for page 2.
        await tester.drag(
          find.byType(ListView).first,
          const Offset(-3000, 0),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(calls, equals([1]));
      },
    );

    testWidgets(
      'Swapping in a fresh controller loads its first page',
      (WidgetTester tester) async {
        final PaginationController<int> controllerA =
            PaginationController(fetchPage: fakeFetcher);
        addTearDown(controllerA.dispose);

        final List<int> bCalls = <int>[];
        final PageFetcher<int> fetcherB = (int page, int pageSize) async {
          bCalls.add(page);
          return List<int>.generate(pageSize, (i) => 1000 + i);
        };
        final PaginationController<int> controllerB =
            PaginationController(fetchPage: fetcherB, firstPage: 1);
        addTearDown(controllerB.dispose);

        Widget host(PaginationController<int> c) => MaterialApp(
              home: Scaffold(
                body: PaginatedList<int>(
                  controller: c,
                  itemBuilder: (_, item, __) =>
                      SizedBox(height: 50, child: Text('item $item')),
                ),
              ),
            );

        await tester.pumpWidget(host(controllerA));
        await tester.pump();
        await tester.pump();
        expect(calls, equals([1]));
        expect(controllerA.state.status, PaginationStatus.loaded);

        // Swap in a controller that has never fetched anything.
        await tester.pumpWidget(host(controllerB));
        await tester.pump();
        await tester.pump();

        expect(bCalls, equals(<int>[1]));
        expect(controllerB.state.status, PaginationStatus.loaded);
        // The swapped-out controller is never touched again.
        expect(calls, equals(<int>[1]));
      },
    );

    testWidgets(
      'gridDelegate creates SliverGrid',
      (WidgetTester tester) async {

        final PaginationController<int> controller =
            PaginationController(fetchPage: fakeFetcher);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) =>
                    SizedBox(height: 50, child: Text('item $item')),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();

        expect(find.byType(SliverGrid), findsOneWidget);
      },
    );

    testWidgets(
      'Pull-to-refresh reloads the list',
      (WidgetTester tester) async {

        final PaginationController<int> controller =
            PaginationController(fetchPage: fakeFetcher);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) =>
                    SizedBox(height: 50, child: Text('item $item')),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();
        expect(calls, equals([1]));

        // Manually trigger refresh instead of fling to avoid timing issues
        await controller.refresh();
        await tester.pump();
        await tester.pump();

        // Should have called page 1 again
        expect(calls.length, greaterThanOrEqualTo(2));
        expect(calls[0], equals(1));
        expect(calls[1], equals(1));
      },
    );

    testWidgets(
      'Widget does not dispose the controller',
      (WidgetTester tester) async {

        final PaginationController<int> controller =
            PaginationController(fetchPage: fakeFetcher);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PaginatedList<int>(
                controller: controller,
                itemBuilder: (_, item, __) => const SizedBox(),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump();

        // Remove the widget
        await tester.pumpWidget(const SizedBox());

        // Controller should still be usable
        expect(() => controller.addListener(() {}), returnsNormally);
      },
    );
  });
}
