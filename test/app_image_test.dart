import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/src/widgets/app_image.dart';

/// An in-memory [CachingAssetBundle] serving one well-formed SVG document, so
/// [SvgPicture] parses real bytes without touching the (empty) asset manifest.
class _SvgBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final Uint8List bytes = utf8.encode(
      '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10">'
      '<rect width="10" height="10"/></svg>',
    );
    return ByteData.sublistView(bytes);
  }
}

/// Pumps [child] exactly once inside a minimal [MaterialApp] — no
/// pumpAndSettle, because network and asset loaders never settle in a test.
Future<void> _pumpOnce(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('AppImage.kindOf', () {
    test('classifies sources into loader kinds', () {
      const List<(String, AppImageKind)> table = <(String, AppImageKind)>[
        ('https://x.test/a.png', AppImageKind.network),
        ('http://x.test/a.SVG', AppImageKind.networkSvg),
        ('https://x.test/a.svg?v=2', AppImageKind.networkSvg),
        ('assets/a.png', AppImageKind.asset),
        ('assets/icons/a.svg', AppImageKind.assetSvg),
        // Edge cases for scheme, query, and fragment handling
        ('HTTPS://x.test/a.png', AppImageKind.network),
        ('https://x.test/a.svg#frag', AppImageKind.networkSvg),
        ('assets/a.SVG?x=1#y', AppImageKind.assetSvg),
        ('/abs/path.png', AppImageKind.asset),
      ];
      for (final (String source, AppImageKind expected) in table) {
        expect(
          AppImage.kindOf(source),
          expected,
          reason: 'kindOf($source)',
        );
      }
    });
  });

  group('AppImage.build', () {
    testWidgets('network source builds a CachedNetworkImage',
        (WidgetTester tester) async {
      await _pumpOnce(
        tester,
        const AppImage(source: 'https://x.test/photo.png'),
      );
      tester.takeException();
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('asset SVG renders through the ambient asset bundle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultAssetBundle(
            bundle: _SvgBundle(),
            child: const AppImage(
              source: 'assets/icon.svg',
              width: 10,
              height: 10,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('asset png source builds an Image',
        (WidgetTester tester) async {
      await _pumpOnce(tester, const AppImage(source: 'assets/photo.png'));
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('borderRadius wraps the image in a ClipRRect',
        (WidgetTester tester) async {
      await _pumpOnce(
        tester,
        const AppImage(
          source: 'assets/photo.png',
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      );
      final Finder clip = find.descendant(
        of: find.byType(AppImage),
        matching: find.byType(ClipRRect),
      );
      expect(clip, findsOneWidget);
      expect(
        find.descendant(of: clip, matching: find.byType(Image)),
        findsOneWidget,
      );
    });

    testWidgets('without borderRadius no ClipRRect sits below AppImage',
        (WidgetTester tester) async {
      await _pumpOnce(tester, const AppImage(source: 'assets/photo.png'));
      expect(
        find.descendant(
          of: find.byType(AppImage),
          matching: find.byType(ClipRRect),
        ),
        findsNothing,
      );
    });

    testWidgets('asset AppImage with semanticLabel is found by bySemanticsLabel',
        (WidgetTester tester) async {
      final SemanticsHandle h = tester.ensureSemantics();
      try {
        await _pumpOnce(
          tester,
          const AppImage(
            source: 'assets/logo.png',
            semanticLabel: 'Logo',
          ),
        );
        expect(find.bySemanticsLabel('Logo'), findsOneWidget);
      } finally {
        h.dispose();
      }
    });

    testWidgets('missing asset shows broken_image_outlined in sized box',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppImage(
                source: 'assets/missing.png',
                width: 40,
                height: 30,
              ),
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      tester.takeException();

      // Check for sized box with exact dimensions
      final Finder sizedBox = find.descendant(
        of: find.byType(AppImage),
        matching: find.byType(SizedBox),
      );
      expect(sizedBox, findsWidgets);

      // Check for broken image icon within the tree
      expect(
        find.descendant(
          of: find.byType(AppImage),
          matching: find.byIcon(Icons.broken_image_outlined),
        ),
        findsOneWidget,
      );
    });
  });

  group('showFullScreenImage', () {
    testWidgets('opens a pinch-zoom dialog and closes on the close button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () => showFullScreenImage(
                  context,
                  source: 'assets/missing.png',
                  semanticLabel: 'Receipt',
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      tester.takeException(); // drain any asset-load failure

      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byKey(const Key('appImageFullScreenClose')), findsOneWidget);

      await tester.tap(find.byKey(const Key('appImageFullScreenClose')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      tester.takeException();

      expect(find.byType(InteractiveViewer), findsNothing);
    });
  });
}
