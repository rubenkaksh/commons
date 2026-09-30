import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/src/widgets/app_carousel.dart';

void main() {
  // Three coloured pages, one Text each, so page changes are visible in the
  // tree and pages are easy to tell apart while scrolling.
  List<Widget> makePages() => <Widget>[
    Container(color: Colors.red, child: const Text('p0')),
    Container(color: Colors.green, child: const Text('p1')),
    Container(color: Colors.blue, child: const Text('p2')),
  ];

  // Standard host for the widget under test.
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  // One indicator dot, keyed by the implementation: Key('appCarouselDot$i').
  Finder dot(int index) => find.byKey(Key('appCarouselDot$index'));

  testWidgets('renders exactly one dot per page, never a hardcoded five', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host(AppCarousel(pages: makePages(), height: 200)));
    await tester.pumpAndSettle();

    expect(dot(0), findsOneWidget);
    expect(dot(1), findsOneWidget);
    expect(dot(2), findsOneWidget);
    // The old widget hardcoded 5 dots; page index 3 must not exist.
    expect(dot(3), findsNothing);
    expect(find.byType(AnimatedContainer), findsNWidgets(3));
  });

  testWidgets('dot 0 is active initially: 26 wide, the rest 14 wide', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host(AppCarousel(pages: makePages(), height: 200)));
    await tester.pumpAndSettle();

    // Dot widths include +6: each AnimatedContainer has horizontal margin 3
    // (3 + 3) on both sides, which tester.getSize captures.
    expect(tester.getSize(dot(0)).width, 26);
    expect(tester.getSize(dot(1)).width, 14);
    expect(tester.getSize(dot(2)).width, 14);
  });

  testWidgets('swiping left calls onPageChanged(1) and widens dot 1', (
    WidgetTester tester,
  ) async {
    final List<int> changes = <int>[];
    await tester.pumpWidget(
      host(
        AppCarousel(
          pages: makePages(),
          height: 200,
          onPageChanged: changes.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(changes, <int>[1]);
    // +6 = horizontal margin 3 on each side, included by tester.getSize.
    expect(tester.getSize(dot(1)).width, 26);
    expect(tester.getSize(dot(0)).width, 14);
    expect(find.text('p1'), findsOneWidget);
  });

  testWidgets('a single page shows no indicator dots', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        AppCarousel(
          pages: <Widget>[Container(color: Colors.red, child: const Text('p0'))],
          height: 200,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(dot(0), findsNothing);
    expect(find.byType(AnimatedContainer), findsNothing);
  });

  testWidgets('showIndicator: false shows no dots', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        AppCarousel(pages: makePages(), height: 200, showIndicator: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(dot(0), findsNothing);
    expect(dot(1), findsNothing);
    expect(dot(2), findsNothing);
    expect(find.byType(AnimatedContainer), findsNothing);
  });

  testWidgets('never disposes a caller-owned controller', (
    WidgetTester tester,
  ) async {
    final PageController controller = PageController();
    await tester.pumpWidget(
      host(
        AppCarousel(
          pages: makePages(),
          height: 200,
          controller: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tear the carousel down. If the widget disposed the caller's controller,
    // touching it below would throw a "used after dispose" FlutterError.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(() => controller.addListener(() {}), returnsNormally);
    controller.dispose();
  });

  testWidgets('controller.jumpToPage(2) shows the third page', (
    WidgetTester tester,
  ) async {
    final PageController controller = PageController();
    await tester.pumpWidget(
      host(
        AppCarousel(
          pages: makePages(),
          height: 200,
          controller: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();

    controller.jumpToPage(2);
    await tester.pumpAndSettle();

    expect(find.text('p2'), findsOneWidget);
    // 20 + 6 = dot width plus horizontal margin 3 on each side.
    expect(tester.getSize(dot(2)).width, 26);

    // Unmount before disposing the controller this test owns.
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('swapping controllers keeps the outgoing one usable', (
    WidgetTester tester,
  ) async {
    final PageController a = PageController();
    final PageController b = PageController();
    PageController current = a;
    late StateSetter setHostState;

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            setHostState = setState;
            return AppCarousel(
              pages: makePages(),
              height: 200,
              controller: current,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Swap the caller's controller a -> b while the carousel is mounted.
    setHostState(() {
      current = b;
    });
    await tester.pumpAndSettle();

    // The carousel must now be driven by b.
    b.jumpToPage(2);
    await tester.pumpAndSettle();
    expect(find.text('p2'), findsOneWidget);

    // a was caller-owned, so the widget must not have disposed it during the
    // swap: touching it after would throw "used after dispose" if it had.
    expect(() => a.addListener(() {}), returnsNormally);

    // Unmount first, then dispose the controllers this test owns.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    a.dispose();
    b.dispose();
  });

  testWidgets('swapping to null and back never disposes the caller controller', (
    WidgetTester tester,
  ) async {
    final PageController caller = PageController();
    PageController? current = caller;
    late StateSetter setHostState;

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            setHostState = setState;
            return AppCarousel(
              pages: makePages(),
              height: 200,
              controller: current,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Caller controller -> widget-owned controller...
    setHostState(() {
      current = null;
    });
    await tester.pumpAndSettle();

    // ...and back to the caller's controller.
    setHostState(() {
      current = caller;
    });
    await tester.pumpAndSettle();

    // The caller's controller survived both swaps untouched.
    expect(() => caller.addListener(() {}), returnsNormally);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    caller.dispose();
  });

  testWidgets('height: null wraps the PageView in a 16:9 AspectRatio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host(AppCarousel(pages: makePages())));
    await tester.pumpAndSettle();

    final Finder aspect = find.ancestor(
      of: find.byType(PageView),
      matching: find.byType(AspectRatio),
    );
    expect(aspect, findsOneWidget);
    expect(tester.widget<AspectRatio>(aspect).aspectRatio, 16 / 9);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('initialPage: 1 makes dot 1 the active one: 26 wide', (
    WidgetTester tester,
  ) async {
    final PageController controller = PageController(initialPage: 1);
    await tester.pumpWidget(
      host(
        AppCarousel(
          pages: makePages(),
          height: 200,
          controller: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // +6 = horizontal margin 3 on each side, included by tester.getSize.
    expect(tester.getSize(dot(1)).width, 26);
    expect(tester.getSize(dot(0)).width, 14);
    expect(tester.getSize(dot(2)).width, 14);
    // The page view itself must start on page 1 as well.
    expect(find.text('p1'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
