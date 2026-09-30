import 'package:flutter/material.dart';

/// Elevated (tonal-shadow) button. Prefer [AppFilledButton] for the primary
/// call to action: it is the Material 3 primary style and adds icon and
/// loading states.
@Deprecated('Use AppFilledButton for primary actions. Removal after v0.9.0.')
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

/// Material 3 filled button with an optional leading [icon] and a loading
/// state that disables the button and shows a progress spinner.
class AppFilledButton extends StatelessWidget {
  /// Creates a filled button with [text], optional [icon], optional
  /// [isLoading] spinner and an [onPressed] handler.
  const AppFilledButton({
    super.key,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.onPressed,
  });

  /// Label rendered inside the button.
  final String text;

  /// Optional widget shown before [text].
  final Widget? icon;

  /// Whether the button is busy: disables [onPressed] and swaps the leading
  /// widget for a progress spinner.
  final bool isLoading;

  /// Called when the button is tapped, or `null` when disabled/loading.
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

/// Outlined button with an optional leading [icon] and a loading state that
/// disables the button and shows a progress spinner.
class AppOutlinedButton extends StatelessWidget {
  /// Creates an outlined button with [text], optional [icon], optional
  /// [isLoading] spinner and an [onPressed] handler.
  const AppOutlinedButton({
    super.key,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.onPressed,
  });

  /// Label rendered inside the button.
  final String text;

  /// Optional widget shown before [text].
  final Widget? icon;

  /// Whether the button is busy: disables [onPressed] and swaps the leading
  /// widget for a progress spinner.
  final bool isLoading;

  /// Called when the button is tapped, or `null` when disabled/loading.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading || icon != null) {
      return OutlinedButton.icon(
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
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

/// Borderless text button with a loading state that disables the button and
/// shows a progress spinner.
class GhostButton extends StatelessWidget {
  /// Creates a ghost (text) button with [text], optional [isLoading] spinner
  /// and an [onPressed] handler.
  const GhostButton({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
  });

  /// Label rendered inside the button.
  final String text;

  /// Whether the button is busy: disables [onPressed] and swaps the button
  /// for a spinner-led variant.
  final bool isLoading;

  /// Called when the button is tapped, or `null` when disabled/loading.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return TextButton.icon(
        onPressed: null,
        icon: const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text(text),
      );
    }
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

/// Icon-only button with an optional [tooltip].
class AppIconButton extends StatelessWidget {
  /// Creates an icon button with [icon], optional [tooltip] and an
  /// [onPressed] handler.
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
