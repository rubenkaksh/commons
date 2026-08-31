import 'package:flutter/material.dart';

enum BadgeTone { primary, success, warning, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = BadgeTone.neutral,
  });

  final String label;
  final Widget? icon;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final (Color bg, Color fg) = switch (tone) {
      BadgeTone.primary => (colors.primaryContainer, colors.onPrimaryContainer),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon case final Widget iconWidget) ...[
            IconTheme(
              data: IconThemeData(size: 14, color: fg),
              child: iconWidget,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
