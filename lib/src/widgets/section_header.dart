import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.leadingIcon,
    this.onTap,
  });

  final String title;
  final Widget? leadingIcon;
  final VoidCallback? onTap;

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
        if (onTap != null)
          IconButton(
            icon: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            onPressed: onTap,
          ),
      ],
    );
  }
}
