import 'package:flutter/material.dart';

import '../l10n/commons_strings.dart';

/// Shows a Material confirm dialog and reports which action dismissed it.
///
/// The returned future completes with `true` only when the confirm action is
/// pressed. The cancel action, a tap on the barrier and the system back
/// gesture all complete it with `false` (a dismissed dialog never yields
/// `true`).
///
/// [title], [message] and [confirmLabel] are caller-supplied — commons never
/// bakes in English. [cancelLabel] falls back to [CommonsStrings.cancel] from
/// the nearest [CommonsStringsScope]. Pass [icon] to lead the dialog with a
/// glyph or illustration; when [message] is null no content body is rendered.
///
/// With [destructive] the confirm button is painted in [ColorScheme.error] /
/// [ColorScheme.onError] so destructive actions read as such; otherwise it
/// keeps the theme's default [FilledButton] styling.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
  Widget? icon,
}) async {
  // Resolved from the caller's context (the dialog route is not guaranteed to
  // sit under an app-provided CommonsStringsScope).
  final String cancel = cancelLabel ?? CommonsStrings.of(context).cancel;
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      final ColorScheme colors = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        icon: icon,
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
