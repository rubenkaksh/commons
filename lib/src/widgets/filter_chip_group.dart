import 'package:flutter/material.dart';

/// A wrapping row of filter chips built on Material [FilterChip]s.
///
/// Every entry of [options] renders one chip whose label is produced by
/// [labelBuilder]. Selection state is owned by the caller: [selected] holds
/// the current values and [onChanged] receives the complete new set after
/// each tap. The incoming [selected] set is never mutated.
///
/// Visual styling comes entirely from the ambient [ChipThemeData], so this
/// widget carries no colour of its own.
class FilterChipGroup<T> extends StatelessWidget {
  /// Creates a filter chip group.
  const FilterChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.labelBuilder,
    this.multiSelect = true,
    this.allowEmpty = true,
    this.spacing = 8,
  });

  /// The values rendered as chips, in the order they should appear.
  final List<T> options;

  /// The currently selected values.
  ///
  /// Only read, never mutated: every change is reported through [onChanged].
  final Set<T> selected;

  /// Called with the complete new selection whenever a chip is toggled.
  final ValueChanged<Set<T>> onChanged;

  /// Builds the label shown inside the chip for a given [options] entry.
  final String Function(T option) labelBuilder;

  /// Whether more than one option may be selected at a time.
  ///
  /// When false, selecting an option clears any other selection.
  final bool multiSelect;

  /// Whether an empty selection is allowed.
  ///
  /// When false, deselecting the last remaining option is ignored (in
  /// single-select mode the current selection is kept instead of cleared).
  final bool allowEmpty;

  /// Horizontal and vertical gap between chips, in logical pixels.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: <Widget>[
        for (final T option in options)
          FilterChip(
            label: Text(labelBuilder(option)),
            selected: selected.contains(option),
            onSelected: (bool isSelected) =>
                onChanged(_next(option, isSelected)),
          ),
      ],
    );
  }

  /// Computes the selection that should follow tapping [option].
  ///
  /// Returns a new set (or [selected] unchanged when the tap would violate
  /// [allowEmpty]) and never modifies the incoming selection.
  Set<T> _next(T option, bool isSelected) {
    if (multiSelect) {
      if (isSelected) {
        return <T>{...selected, option};
      }
      final Set<T> next = <T>{...selected}..remove(option);
      if (!allowEmpty && next.isEmpty) {
        return selected;
      }
      return next;
    }
    if (isSelected) {
      return <T>{option};
    }
    return allowEmpty ? <T>{} : selected;
  }
}
