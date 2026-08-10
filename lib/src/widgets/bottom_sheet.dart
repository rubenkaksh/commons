import 'package:flutter/material.dart' as m;

/// A generic bottom sheet with title, scrollable body, and confirm/cancel CTAs.
///
/// Use [showFormBottomSheet] to display this as a modal bottom sheet.
///
/// Keyboard handling is built in generically: the sheet insets its bottom by
/// the current keyboard height (via [m.MediaQuery.viewInsetsOf]) so focused
/// inputs and the CTAs stay visible, and [showFormBottomSheet] autofocuses
/// the first focusable widget (the primary input) on open. Every form sheet
/// built on these two gets both behaviors for free — no per-sheet keyboard
/// code.
class FormBottomSheet extends m.StatelessWidget {
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
  final m.Widget body;
  final String confirmLabel;
  final m.VoidCallback? onConfirm;
  final String cancelLabel;
  final m.VoidCallback? onCancel;
  final bool confirmEnabled;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    // The sheet must wrap its content (min height), so there is no Scaffold —
    // a Scaffold always expands to fill its constraints and would turn the
    // sheet full-screen. Keyboard handling instead lives in this root
    // AnimatedPadding: the sheet lifts by the keyboard height as a whole
    // (resize-to-avoid-bottom-inset semantics). It sits OUTSIDE the content
    // so the sheet re-sizes above the keyboard instead of shrinking its child.
    return m.AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: m.Curves.easeOut,
      padding: m.EdgeInsets.only(bottom: m.MediaQuery.viewInsetsOf(context).bottom),
      child: m.Container(
        decoration: m.BoxDecoration(
          color: colors.surface,
          borderRadius: const m.BorderRadius.vertical(top: m.Radius.circular(20)),
        ),
        child: m.SingleChildScrollView(
          child: m.Column(
            mainAxisSize: m.MainAxisSize.min,
            children: <m.Widget>[
              // Header
              m.Padding(
                padding: const m.EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: m.Column(
                  crossAxisAlignment: m.CrossAxisAlignment.start,
                  children: <m.Widget>[
                    m.Text(
                      title,
                      style: m.Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (subtitle case final subtitle?) ...[
                      const m.SizedBox(height: 4),
                      m.Text(
                        subtitle,
                        style: m.Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Scrollable body
              m.Padding(
                padding: const m.EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: body,
              ),
              // CTAs
              m.Padding(
                padding: const m.EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: m.Row(
                  children: <m.Widget>[
                    m.Expanded(
                      child: m.OutlinedButton(
                        onPressed: onCancel ?? () => m.Navigator.pop(context),
                        child: m.Text(cancelLabel),
                      ),
                    ),
                    const m.SizedBox(width: 12),
                    m.Expanded(
                      child: m.FilledButton(
                        onPressed: confirmEnabled ? onConfirm : null,
                        child: m.Text(confirmLabel),
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
  required m.BuildContext context,
  required m.WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return m.showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    builder: (m.BuildContext sheetContext) {
      // Generic focus-on-open: focuses the first focusable widget in the
      // sheet (i.e. the primary input) after the first frame, so the keyboard
      // is up as soon as the sheet appears — without per-sheet code. A sheet
      // with no focusables (e.g. plain confirmation) is a no-op.
      return _PrimaryFocusScope(child: builder(sheetContext));
    },
  );
}

/// Wraps the sheet content in a [m.FocusScope] that focuses the first
/// focusable widget on open.
class _PrimaryFocusScope extends m.StatefulWidget {
  const _PrimaryFocusScope({required this.child});

  final m.Widget child;

  @override
  m.State<_PrimaryFocusScope> createState() => _PrimaryFocusScopeState();
}

class _PrimaryFocusScopeState extends m.State<_PrimaryFocusScope> {
  final m.FocusScopeNode _scopeNode = m.FocusScopeNode();

  @override
  void initState() {
    super.initState();
    // Note: `FocusScope(autofocus: true)` alone is NOT enough — it focuses the
    // scope node but does not descend into the first focusable child, so the
    // keyboard would stay down. Traverse explicitly instead.
    m.WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final Iterable<m.FocusNode> focusables = _scopeNode.traversalDescendants;
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
  m.Widget build(m.BuildContext context) {
    return m.FocusScope(node: _scopeNode, child: widget.child);
  }
}
