import 'package:flutter/material.dart' as m;

class PrimaryButton extends m.StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  final String text;
  final m.VoidCallback? onPressed;

  @override
  m.Widget build(m.BuildContext context) {
    return m.ElevatedButton(
      onPressed: onPressed,
      child: m.Text(text),
    );
  }
}

class FilledButton extends m.StatelessWidget {
  const FilledButton({
    super.key,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.onPressed,
  });

  final String text;
  final m.Widget? icon;
  final bool isLoading;
  final m.VoidCallback? onPressed;

  @override
  m.Widget build(m.BuildContext context) {
    if (isLoading || icon != null) {
      return m.FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const m.SizedBox.square(
                dimension: 18,
                child: m.CircularProgressIndicator(strokeWidth: 2),
              )
            : icon ?? const m.SizedBox.shrink(),
        label: m.Text(text),
      );
    }
    return m.FilledButton(
      onPressed: onPressed,
      child: m.Text(text),
    );
  }
}

class OutlineButton extends m.StatelessWidget {
  const OutlineButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
  });

  final String text;
  final m.Widget? icon;
  final m.VoidCallback? onPressed;

  @override
  m.Widget build(m.BuildContext context) {
    if (icon case final m.Widget iconWidget) {
      return m.OutlinedButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: m.Text(text),
      );
    }
    return m.OutlinedButton(
      onPressed: onPressed,
      child: m.Text(text),
    );
  }
}

class GhostButton extends m.StatelessWidget {
  const GhostButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  final String text;
  final m.VoidCallback? onPressed;

  @override
  m.Widget build(m.BuildContext context) {
    return m.TextButton(
      onPressed: onPressed,
      child: m.Text(text),
    );
  }
}

class IconButton extends m.StatelessWidget {
  const IconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  final m.Widget icon;
  final m.VoidCallback? onPressed;
  final String? tooltip;

  @override
  m.Widget build(m.BuildContext context) {
    return m.IconButton(
      onPressed: onPressed,
      icon: icon,
      tooltip: tooltip,
    );
  }
}
