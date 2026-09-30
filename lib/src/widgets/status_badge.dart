import 'package:flutter/material.dart';

import '../theme/color_extensions.dart';

/// Semantic role used to derive a [StatusBadge]'s default background and
/// foreground from the ambient [ColorScheme].
enum BadgeTone {
  /// Primary container background with its matching on-colour foreground.
  primary,

  /// Secondary container background (typically "success" / positive states).
  success,

  /// Tertiary container background (typically "warning" / attention states).
  warning,

  /// Surface-container background with a muted foreground, for low-emphasis
  /// or purely informational badges.
  neutral,
}

/// A compact pill that renders a status label, optionally with an [icon].
///
/// Colours always come from [Theme.of].colorScheme: either the [tone]'s
/// container/on-colour pair, or the custom [color] (which overrides [tone]).
class StatusBadge extends StatelessWidget {
  /// Creates a status badge.
  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = BadgeTone.neutral,
    this.color,
    this.outlined = false,
  });

  /// The badge text.
  final String label;

  /// Optional leading icon, rendered at 14 logical pixels in the foreground
  /// colour.
  final Widget? icon;

  /// The semantic role used when no custom [color] is supplied.
  final BadgeTone tone;

  /// Custom background colour; when non-null it overrides [tone].
  ///
  /// The foreground is derived with [OnColor.onColor] so text and icon stay
  /// legible against this colour.
  final Color? color;

  /// When true, the badge is drawn "as a tag": clear background
  /// ([ColorScheme.surface] at alpha 0) with a 1px border in the resolved
  /// foreground-role colour, and text/icon in that same colour.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color? custom = color;

    final (Color bg, Color fg) = custom != null
        ? (custom, custom.onColor())
        : switch (tone) {
            BadgeTone.primary => (
              colors.primaryContainer,
              colors.onPrimaryContainer,
            ),
            BadgeTone.success => (
              colors.secondaryContainer,
              colors.onSecondaryContainer,
            ),
            BadgeTone.warning => (
              colors.tertiaryContainer,
              colors.onTertiaryContainer,
            ),
            BadgeTone.neutral => (
              colors.surfaceContainerHighest,
              colors.onSurfaceVariant,
            ),
          };

    // Outlined badges show their hue as border + text on a clear background:
    // the custom colour itself when supplied, else the tone's foreground.
    final Color accent = custom != null ? bg : fg;
    final Color background = outlined
        ? colors.surface.withValues(alpha: 0)
        : bg;
    final Color foreground = outlined ? accent : fg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: outlined ? Border.all(color: accent, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon case final Widget iconWidget) ...[
            IconTheme(
              data: IconThemeData(size: 14, color: foreground),
              child: iconWidget,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
