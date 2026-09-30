import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/src/theme/color_extensions.dart';
import 'package:commons/src/widgets/status_badge.dart';

void main() {
  // The theme every case renders against: a teal-seeded Material 3 scheme.
  Future<void> pumpBadge(
    WidgetTester tester, {
    required StatusBadge badge,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: Center(child: badge),
      ),
    );
    await tester.pump();
  }

  // The badge's own Container carries the decoration under test.
  BoxDecoration decorationOf(WidgetTester tester) {
    final Container container = tester.widget<Container>(
      find.descendant(
        of: find.byType(StatusBadge),
        matching: find.byType(Container),
      ),
    );
    final Decoration? decoration = container.decoration;
    if (decoration is BoxDecoration) {
      return decoration;
    }
    throw StateError(
      'StatusBadge must paint with BoxDecoration, got $decoration',
    );
  }

  // The scheme the badge actually rendered against, read back from the tree
  // so assertions compare against the widget's own ColorScheme.
  ColorScheme schemeOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(StatusBadge))).colorScheme;

  Text labelOf(WidgetTester tester) => tester.widget<Text>(
    find.descendant(of: find.byType(StatusBadge), matching: find.byType(Text)),
  );

  Color labelColorOf(WidgetTester tester) {
    final Color? color = labelOf(tester).style?.color;
    if (color == null) {
      throw StateError('the label Text must carry a colour');
    }
    return color;
  }

  group('StatusBadge API', () {
    test('defaults match the documented API', () {
      const StatusBadge badge = StatusBadge(label: 'Off');

      expect(badge.label, 'Off');
      expect(badge.icon, isNull);
      expect(badge.tone, BadgeTone.neutral);
      expect(badge.color, isNull, reason: 'colour must come from the tone');
      expect(badge.outlined, isFalse);
    });
  });

  group('tone resolution', () {
    testWidgets('default (neutral) uses surfaceContainerHighest', (
      WidgetTester tester,
    ) async {
      await pumpBadge(tester, badge: const StatusBadge(label: 'Idle'));

      final ColorScheme colors = schemeOf(tester);
      expect(decorationOf(tester).color, colors.surfaceContainerHighest);
      expect(labelColorOf(tester), colors.onSurfaceVariant);
      expect(
        decorationOf(tester).border,
        isNull,
        reason: 'a filled badge carries no border',
      );
    });

    for (final BadgeTone tone in BadgeTone.values) {
      testWidgets('${tone.name} maps to its container colour', (
        WidgetTester tester,
      ) async {
        await pumpBadge(
          tester,
          badge: StatusBadge(label: tone.name, tone: tone),
        );

        final ColorScheme colors = schemeOf(tester);
        final Color expectedBackground = switch (tone) {
          BadgeTone.primary => colors.primaryContainer,
          BadgeTone.success => colors.secondaryContainer,
          BadgeTone.warning => colors.tertiaryContainer,
          BadgeTone.neutral => colors.surfaceContainerHighest,
        };
        final Color expectedForeground = switch (tone) {
          BadgeTone.primary => colors.onPrimaryContainer,
          BadgeTone.success => colors.onSecondaryContainer,
          BadgeTone.warning => colors.onTertiaryContainer,
          BadgeTone.neutral => colors.onSurfaceVariant,
        };

        expect(decorationOf(tester).color, expectedBackground);
        expect(labelColorOf(tester), expectedForeground);
      });
    }
  });

  group('custom colour', () {
    testWidgets('dark blue background takes a white label, overriding tone', (
      WidgetTester tester,
    ) async {
      const Color custom = Color(0xFF0D47A1);
      await pumpBadge(
        tester,
        badge: const StatusBadge(
          label: 'Info',
          icon: Icon(Icons.info_outline),
          tone: BadgeTone.primary,
          color: custom,
        ),
      );

      expect(decorationOf(tester).color, custom);
      expect(labelColorOf(tester), const Color(0xFFFFFFFF));
      expect(labelColorOf(tester), custom.onColor());
      // The icon shares the label's derived foreground.
      final IconTheme iconTheme = tester.widget<IconTheme>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(IconTheme),
        ),
      );
      expect(iconTheme.data.color, const Color(0xFFFFFFFF));
    });

    testWidgets('yellow background takes a black label', (
      WidgetTester tester,
    ) async {
      const Color custom = Color(0xFFFFEB3B);
      await pumpBadge(
        tester,
        badge: const StatusBadge(label: 'Warn', color: custom),
      );

      expect(decorationOf(tester).color, custom);
      expect(labelColorOf(tester), const Color(0xFF000000));
      expect(labelColorOf(tester), custom.onColor());
    });
  });

  group('outlined (tag) style', () {
    testWidgets('tone badge: clear background, border == text colour', (
      WidgetTester tester,
    ) async {
      await pumpBadge(
        tester,
        badge: const StatusBadge(label: 'Beta', outlined: true),
      );

      final BoxDecoration decoration = decorationOf(tester);
      if (decoration.color case final Color background) {
        expect(background.a, 0.0, reason: 'background must be fully clear');
        expect(background, schemeOf(tester).surface.withValues(alpha: 0));
      } else {
        fail('outlined badge must still paint a background colour slot');
      }

      if (decoration.border case final Border border) {
        expect(border.top.width, 1.0, reason: 'hairline 1px border');
        expect(
          border.top.color,
          labelColorOf(tester),
          reason: 'border and text share the accent colour',
        );
        // For tones the accent is the tone's foreground colour.
        expect(border.top.color, schemeOf(tester).onSurfaceVariant);
      } else {
        fail('outlined badge must carry a Border, was ${decoration.border}');
      }
    });

    testWidgets('custom colour: its hue is the border and the text', (
      WidgetTester tester,
    ) async {
      const Color custom = Color(0xFF0D47A1);
      await pumpBadge(
        tester,
        badge: const StatusBadge(label: 'Tag', color: custom, outlined: true),
      );

      final BoxDecoration decoration = decorationOf(tester);
      if (decoration.color case final Color background) {
        expect(background.a, 0.0);
      } else {
        fail('outlined badge must still paint a background colour slot');
      }

      expect(labelColorOf(tester), custom);

      if (decoration.border case final Border border) {
        expect(border.top.color, custom);
        expect(border.top.color, labelColorOf(tester));
      } else {
        fail('outlined badge must carry a Border, was ${decoration.border}');
      }
    });

    testWidgets('outlined: false keeps a filled, borderless badge', (
      WidgetTester tester,
    ) async {
      await pumpBadge(
        tester,
        badge: const StatusBadge(label: 'Filled', outlined: false),
      );

      final BoxDecoration decoration = decorationOf(tester);
      expect(decoration.border, isNull);
      if (decoration.color case final Color background) {
        expect(background.a, greaterThan(0.0));
      } else {
        fail('a filled badge must paint a background colour');
      }
    });
  });

  group('icon', () {
    testWidgets('is shown when given, next to the label', (
      WidgetTester tester,
    ) async {
      await pumpBadge(
        tester,
        badge: const StatusBadge(label: 'Sync', icon: Icon(Icons.sync)),
      );

      expect(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Icon),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );
    });

    testWidgets('is omitted when not given', (WidgetTester tester) async {
      await pumpBadge(tester, badge: const StatusBadge(label: 'Sync'));

      expect(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Icon),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );
    });
  });
}
