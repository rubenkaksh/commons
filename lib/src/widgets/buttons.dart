import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class AppFilledButton extends StatelessWidget {
  const AppFilledButton({
    super.key,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.onPressed,
  });

  final String text;
  final Widget? icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading || icon != null) {
      return FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : icon ?? const SizedBox.shrink(),
        label: Text(text),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
  });

  final String text;
  final Widget? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (icon case final Widget iconWidget) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: Text(text),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      tooltip: tooltip,
    );
  }
}
