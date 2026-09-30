import 'package:flutter/material.dart';

/// A titled row used to introduce a section of a screen.
///
/// Renders an optional [leadingIcon], the [title], and a trailing slot: by
/// default an [IconButton] with a chevron that triggers [onTap], or the custom
/// [action] widget when one is supplied.
class SectionHeader extends StatelessWidget {
  /// Creates a section header.
  const SectionHeader({
    super.key,
    required this.title,
    this.leadingIcon,
    this.onTap,
    this.action,
  });

  /// The text displayed at the start of the header.
  final String title;

  /// An optional widget shown before [title].
  final Widget? leadingIcon;

  /// Called when the trailing chevron [IconButton] is pressed.
  ///
  /// Ignored while [action] is provided, since the chevron is then replaced.
  final VoidCallback? onTap;

  /// An optional custom widget rendered at the trailing end of the header.
  ///
  /// When non-null it replaces the chevron [IconButton] entirely; when null the
  /// chevron is shown if [onTap] is provided.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        if (leadingIcon case final Widget icon) ...[
          icon,
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (action case final Widget trailing)
          trailing
        else if (onTap != null)
          IconButton(
            icon: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            onPressed: onTap,
          ),
      ],
    );
  }
}
