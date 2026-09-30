import 'package:flutter/material.dart';

/// A horizontal row of overlapping circular avatars with an optional
/// "+N" overflow indicator.
///
/// Each entry of [avatars] is clipped to a circle of diameter [size] and
/// positioned at a step of `size * (1 - overlap)`, so consecutive avatars
/// overlap by the [overlap] fraction of [size]. The stack is wrapped in a
/// fixed-size [SizedBox] because a bare [Stack] containing only [Positioned]
/// children lays out at zero size. Every slot carries a circular border of
/// [borderWidth] in [ColorScheme.surface] so overlapping neighbours separate
/// visually ([Container] insets its child by the border, keeping the ring
/// visible).
///
/// When [maxVisible] is set and [avatars] holds more entries than it, the
/// first [maxVisible] avatars are followed by a "+N" circle where N is the
/// number of hidden avatars; that circle is painted with
/// [ColorScheme.secondaryContainer] and [ColorScheme.onSecondaryContainer]
/// text in [TextStyle.labelSmall] style. An empty [avatars] list renders a
/// zero-size [SizedBox.shrink].
class AvatarStack extends StatelessWidget {
  /// Creates a stack of overlapping circular [avatars].
  ///
  /// [overlap] must satisfy `0 <= overlap < 1`.
  const AvatarStack({
    super.key,
    required this.avatars,
    this.size = 32,
    this.overlap = 0.3,
    this.maxVisible,
    this.borderWidth = 2,
  })  : assert(overlap >= 0 && overlap < 1),
        assert(maxVisible == null || maxVisible >= 0,
            'maxVisible must be non-negative');

  /// The avatar widgets to lay out, left to right; each is clipped to a
  /// circle of diameter [size].
  final List<Widget> avatars;

  /// Diameter of every avatar slot, in logical pixels.
  final double size;

  /// How far each avatar overlaps the previous one, as a fraction of [size]:
  /// `0` places avatars edge to edge, values near `1` stack them almost on
  /// top of each other. Must be `>= 0` and `< 1`.
  final double overlap;

  /// When non-null and [avatars] is longer, only the first [maxVisible]
  /// avatars are shown, followed by a "+N" circle counting the rest.
  final int? maxVisible;

  /// Width of the circular ring drawn around each slot in
  /// [ColorScheme.surface] to separate overlapping avatars.
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    if (avatars.isEmpty) {
      return const SizedBox.shrink();
    }

    final int? cap = maxVisible;
    int visibleCount = avatars.length;
    int overflowCount = 0;
    if (cap != null && avatars.length > cap) {
      visibleCount = cap;
      overflowCount = avatars.length - cap;
    }

    final double step = size * (1 - overlap);
    final List<Widget> slots = <Widget>[
      for (int i = 0; i < visibleCount; i++)
        _buildAvatar(context, avatars[i]),
      if (overflowCount > 0) _buildOverflow(context, overflowCount),
    ];

    return SizedBox(
      width: size + (slots.length - 1) * step,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          for (int i = 0; i < slots.length; i++)
            Positioned(
              left: i * step,
              top: 0,
              width: size,
              height: size,
              child: slots[i],
            ),
        ],
      ),
    );
  }

  /// One circular slot holding [child], ringed with [borderWidth] of
  /// [ColorScheme.surface].
  Widget _slot(BuildContext context, Widget child, {Color? background}) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(width: borderWidth, color: colors.surface),
      ),
      child: ClipOval(child: child),
    );
  }

  /// The circular clip for a single avatar widget.
  Widget _buildAvatar(BuildContext context, Widget avatar) {
    return _slot(context, SizedBox.square(dimension: size, child: avatar));
  }

  /// The "+N" circle shown in place of the avatars hidden by [maxVisible].
  Widget _buildOverflow(BuildContext context, int hiddenCount) {
    final ThemeData theme = Theme.of(context);
    return _slot(
      context,
      SizedBox.square(
        dimension: size,
        child: Center(
          child: Text(
            '+$hiddenCount',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
      background: theme.colorScheme.secondaryContainer,
    );
  }
}
