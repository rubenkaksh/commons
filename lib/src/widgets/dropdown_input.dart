import 'package:flutter/material.dart';

/// Dropdown select built in the style of the shared input family
/// (`TextInput`/`PasswordInput`): the same [InputDecoration] contract
/// (label/hint/error) with a Material dropdown picker.
///
/// Generic over [T] so the value can stay a raw id while the label differs
/// (e.g. the turf selection screen shows raw turf ids today and will show
/// friendly names later without changing callers).
class DropdownInput<T> extends StatelessWidget {
  const DropdownInput({
    super.key,
    required this.label,
    required this.items,
    this.hint,
    this.error,
    this.value,
    this.enabled = true,
    this.onChanged,
  });

  final String label;
  final String? hint;
  final String? error;
  final bool enabled;

  /// Dropdown entries as `(value, label)` pairs.
  final List<(T value, String label)> items;

  /// Currently selected value (null = nothing selected).
  final T? value;

  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
      ),
      items: <DropdownMenuItem<T>>[
        for (final (T value, String label) in items)
          DropdownMenuItem<T>(
            value: value,
            child: Text(label),
          ),
      ],
      // A null onChanged renders the field disabled (Flutter 3.32 idiom).
      onChanged: enabled ? onChanged : null,
    );
  }
}
