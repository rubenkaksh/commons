import 'package:flutter/material.dart';

/// A generic bottom sheet with title, scrollable body, and confirm/cancel CTAs.
///
/// Use [showFormBottomSheet] to display this as a modal bottom sheet.
///
/// Keyboard handling is built in generically: the sheet insets its bottom by
/// the current keyboard height (via [MediaQuery.viewInsetsOf]) so focused
/// inputs and the CTAs stay visible, and [showFormBottomSheet] autofocuses
/// the first focusable widget (the primary input) on open. Every form sheet
/// built on these two gets both behaviors for free — no per-sheet keyboard
/// code.
class FormBottomSheet extends StatelessWidget {
  const FormBottomSheet({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.onConfirm,
    this.subtitle,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.confirmEnabled = true,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final String confirmLabel;
  final VoidCallback? onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;
  final bool confirmEnabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    // The sheet must wrap its content (min height), so there is no Scaffold —
    // a Scaffold always expands to fill its constraints and would turn the
    // sheet full-screen. Keyboard handling instead lives in this root
    // AnimatedPadding: the sheet lifts by the keyboard height as a whole
    // (resize-to-avoid-bottom-inset semantics). It sits OUTSIDE the content
    // so the sheet re-sizes above the keyboard instead of shrinking its child.
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (subtitle case final subtitle?) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Scrollable body
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: body,
              ),
              // CTAs
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel ?? () => Navigator.pop(context),
                        child: Text(cancelLabel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: confirmEnabled ? onConfirm : null,
                        child: Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a modal bottom sheet with [FormBottomSheet] content.
///
/// Returns a [Future] that completes with the value passed to
/// [Navigator.pop] when the sheet is dismissed.
Future<T?> showFormBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    builder: (BuildContext sheetContext) {
      // Generic focus-on-open: focuses the first focusable widget in the
      // sheet (i.e. the primary input) after the first frame, so the keyboard
      // is up as soon as the sheet appears — without per-sheet code. A sheet
      // with no focusables (e.g. plain confirmation) is a no-op.
      return _PrimaryFocusScope(child: builder(sheetContext));
    },
  );
}

/// Wraps the sheet content in a [FocusScope] that focuses the first
/// focusable widget on open.
class _PrimaryFocusScope extends StatefulWidget {
  const _PrimaryFocusScope({required this.child});

  final Widget child;

  @override
  State<_PrimaryFocusScope> createState() => _PrimaryFocusScopeState();
}

class _PrimaryFocusScopeState extends State<_PrimaryFocusScope> {
  final FocusScopeNode _scopeNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    // Note: `FocusScope(autofocus: true)` alone is NOT enough — it focuses the
    // scope node but does not descend into the first focusable child, so the
    // keyboard would stay down. Traverse explicitly instead.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final Iterable<FocusNode> focusables = _scopeNode.traversalDescendants;
      if (focusables.isEmpty) {
        return;
      }
      _scopeNode.requestFocus(focusables.first);
    });
  }

  @override
  void dispose() {
    _scopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(node: _scopeNode, child: widget.child);
  }
}
