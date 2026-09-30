import 'package:flutter/material.dart';

/// A horizontally swipeable carousel of [pages] with an optional animated
/// dot indicator.
///
/// Replaces the previous ImageCarousel / ImageCarouselWithPageIndicator /
/// CarouselPageIndicator / PaginatedPageView quartet with a single widget
/// built on the framework's own [PageView] (no carousel package).
///
/// The carousel is always height-bounded: pass [height] for an exact size,
/// or leave it null to get a 16:9 [AspectRatio]. Supply [controller] to drive
/// the carousel from the caller — a caller-owned controller is never disposed
/// by this widget, only one it creates itself.
class AppCarousel extends StatefulWidget {
  /// Creates a carousel showing [pages] in order.
  const AppCarousel({
    super.key,
    required this.pages,
    this.controller,
    this.height,
    this.showIndicator = true,
    this.onPageChanged,
  });

  /// The widgets shown one per page, in swipe order.
  final List<Widget> pages;

  /// Optional caller-owned controller used to drive the carousel.
  ///
  /// When null the widget creates its own controller (starting at page 0) and
  /// disposes it on teardown; when provided, disposal stays with the caller.
  final PageController? controller;

  /// Fixed height of the page area. When null, a 16:9 aspect ratio bounds it.
  final double? height;

  /// Whether to render the dot indicator below the pages.
  ///
  /// The indicator is also hidden automatically when fewer than two [pages]
  /// are present.
  final bool showIndicator;

  /// Called with the new index whenever the visible page settles on a change.
  final ValueChanged<int>? onPageChanged;

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

/// State for [AppCarousel]; tracks the active page and owns the controller
/// only when the caller did not supply one.
class _AppCarouselState extends State<AppCarousel> {
  /// The controller this state created itself, or null while a caller-supplied
  /// controller is in use. Only this one is ever disposed by the widget.
  PageController? _ownedController;

  /// Controller actually driving the [PageView]; never null after
  /// [initState] (either the caller's or [_ownedController]).
  late PageController _controller;

  /// Index of the page currently shown, seeded from the controller's
  /// [PageController.initialPage].
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _ownedController = widget.controller == null ? PageController() : null;
    // The coalesce is non-null by construction: it falls back to the owned
    // controller (creating it only if the line above did not already).
    _controller = widget.controller ?? (_ownedController ??= PageController());
    _page = _controller.initialPage;
  }

  @override
  void didUpdateWidget(covariant AppCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final PageController? previouslyOwned = _ownedController;
      if (widget.controller case final PageController external) {
        _ownedController = null;
        _controller = external;
      } else {
        final PageController created = PageController();
        _ownedController = created;
        _controller = created;
      }
      // The outgoing PageView may still be attached until this frame ends,
      // so defer disposal of the controller we owned (never a caller's).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        previouslyOwned?.dispose();
      });
      _page = _controller.initialPage;
    }
    if (_page >= widget.pages.length) {
      _page = widget.pages.isEmpty ? 0 : widget.pages.length - 1;
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PageView view = PageView(
      controller: _controller,
      onPageChanged: (int index) {
        setState(() {
          _page = index;
        });
        widget.onPageChanged?.call(index);
      },
      children: widget.pages,
    );

    final Widget boundedView = widget.height == null
        ? AspectRatio(aspectRatio: 16 / 9, child: view)
        : SizedBox(height: widget.height, child: view);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        boundedView,
        if (widget.showIndicator && widget.pages.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _Indicator(count: widget.pages.length, active: _page),
          ),
      ],
    );
  }
}

/// Row of animated dots, one per page, with the active dot widened.
///
/// Colours come from the theme's [ColorScheme]; there are no literal colours
/// and no text, so nothing needs localising.
class _Indicator extends StatelessWidget {
  /// Creates an indicator with [count] dots highlighting [active].
  const _Indicator({required this.count, required this.active});

  /// Total number of dots to render.
  final int count;

  /// Index of the widened, highlighted dot.
  final int active;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        count,
        (int i) => AnimatedContainer(
          key: Key('appCarouselDot$i'),
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: i == active
                ? colors.primary
                : colors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
