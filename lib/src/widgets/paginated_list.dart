import 'package:flutter/material.dart';

import '../l10n/commons_strings.dart';
import 'feedback.dart';
import 'pagination_controller.dart';

/// A scrollable list that pages itself in from a [PaginationController].
///
/// Fetching is deliberately kept out of the build phase: the first page is
/// requested one frame after the state is created, and every later page is
/// requested either from a [ScrollNotification] that reaches
/// [loadMoreExtent] or from a post-frame check that tops the list up while its
/// content still leaves the viewport empty. [itemBuilder] only ever paints
/// items it is handed — it never triggers a fetch, so building a row can never
/// re-enter the controller.
///
/// Pull-to-refresh delegates to [PaginationController.refresh] and becomes
/// available once items are shown — the refreshable scroll view only exists
/// in that branch. While refreshing, the first page shows the full loading
/// view rather than the list with a spinner appended; that is by design, so
/// stale items are never painted under a refresh. The [controller] itself
/// stays owned by the caller: this widget listens to it but never disposes
/// it. The same holds for [scrollController] — only a scroll controller
/// created internally is disposed with the state.
class PaginatedList<T> extends StatefulWidget {
  /// Creates a paginated list driven by [controller].
  const PaginatedList({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.gridDelegate,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadMoreExtent = 200,
    this.padding,
    this.scrollController,
  });

  /// Owns the items, the [PaginationStatus] and every page fetch; the caller
  /// creates it and keeps it alive across rebuilds.
  final PaginationController<T> controller;

  /// Builds the widget for the item at [index].
  ///
  /// Called for indices `0 .. items.length - 1` only, and never as a place to
  /// start a fetch.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// When non-null the items are laid out as a [SliverGrid] with this
  /// delegate; when null they are laid out as a [SliverList].
  final SliverGridDelegate? gridDelegate;

  /// Builds the placeholder shown when loading finished with no items at all.
  ///
  /// Falls back to a default [EmptyView] when null.
  final WidgetBuilder? emptyBuilder;

  /// Builds the full-screen error shown when the first page fails, receiving
  /// the failure and a callback that retries the load.
  ///
  /// Falls back to an [ErrorView] with the generic message when null.
  final Widget Function(
    BuildContext context,
    Object? error,
    VoidCallback retry,
  )?
  errorBuilder;

  /// Distance, in logical pixels, from the end of the content at which the
  /// next page is requested while scrolling. Defaults to `200`.
  final double loadMoreExtent;

  /// Padding around the items. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? padding;

  /// Scroll controller for the list.
  ///
  /// When null the state creates and owns one, disposing it on teardown; when
  /// provided it is attached to the scroll view as-is and never disposed.
  final ScrollController? scrollController;

  /// Creates the state that listens to the controller.
  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

/// Listener and scroll plumbing for [PaginatedList].
///
/// Owns only the scroll controller it created itself; the pagination
/// controller always stays with the caller.
class _PaginatedListState<T> extends State<PaginatedList<T>> {
  /// The scroll controller created because the caller passed no
  /// [PaginatedList.scrollController]; null when the caller's own is used.
  ScrollController? _ownScrollController;

  /// The controller attached to the scroll view: the caller's when provided,
  /// otherwise the owned one, created on first use.
  ScrollController get _scroll {
    final ScrollController? external = widget.scrollController;
    if (external != null) {
      return external;
    }
    return _ownScrollController ??= ScrollController();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
    if (widget.controller.state.status == PaginationStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.controller.loadNextPage();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant PaginatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
      // A swapped-in controller that never loaded anything is in the same
      // position as a freshly created one, so it gets the same post-frame
      // kick rather than waiting for a scroll that may never come.
      if (widget.controller.state.status == PaginationStatus.initial) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.controller.loadNextPage();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // The caller owns the controller: only the listener goes away here.
    widget.controller.removeListener(_onChange);
    _ownScrollController?.dispose();
    super.dispose();
  }

  /// Rebuilds from the controller, then once the frame has settled asks for
  /// the next page when the content does not fill the viewport yet.
  void _onChange() {
    if (!mounted) {
      return;
    }
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final ScrollController? scroll =
          widget.scrollController ?? _ownScrollController;
      if (scroll == null || !scroll.hasClients) {
        return;
      }
      if (scroll.position.maxScrollExtent > 0) {
        return;
      }
      final PaginationState<T> state = widget.controller.state;
      if (state.isLoading ||
          state.hasReachedEnd ||
          state.status == PaginationStatus.error) {
        return;
      }
      widget.controller.loadNextPage();
    });
  }

  /// Requests the next page when the viewport comes within
  /// [PaginatedList.loadMoreExtent] of the end of the content.
  ///
  /// Notifications from scrollables nested inside this list are ignored: only
  /// this list's own scrolling pages it. Always returns false so that other
  /// listeners still receive the notification. The controller ignores a
  /// request that is already in flight, so a burst of scroll events costs at
  /// most one fetch.
  bool _onScrollNotification(ScrollNotification notification) {
    // depth > 0 means the notification bubbled up from a descendant
    // scrollable, not from the [CustomScrollView] built below.
    if (notification.depth != 0) {
      return false;
    }
    final PaginationState<T> state = widget.controller.state;
    if (notification.metrics.extentAfter <= widget.loadMoreExtent &&
        !state.isLoading &&
        !state.hasReachedEnd &&
        state.status != PaginationStatus.error) {
      widget.controller.loadNextPage();
    }
    return false;
  }

  /// The trailing row shown under the items: a spinner while a page is in
  /// flight, a retry button after a failed page, nothing otherwise.
  Widget _footer(PaginationState<T> state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.status == PaginationStatus.error && state.items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TextButton(
            onPressed: widget.controller.loadNextPage,
            child: Text(CommonsStrings.of(context).retry),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final PaginationState<T> state = widget.controller.state;
    if (state.status == PaginationStatus.initial ||
        (state.isLoading && state.items.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == PaginationStatus.error && state.items.isEmpty) {
      return widget.errorBuilder?.call(
            context,
            state.error,
            widget.controller.loadNextPage,
          ) ??
          ErrorView(
            message: CommonsStrings.of(context).genericError,
            onRetry: widget.controller.loadNextPage,
          );
    }
    if (state.isEmpty) {
      return widget.emptyBuilder?.call(context) ?? const EmptyView();
    }

    final List<T> items = state.items;
    final SliverGridDelegate? grid = widget.gridDelegate;
    final SliverChildBuilderDelegate itemDelegate = SliverChildBuilderDelegate(
      (BuildContext itemContext, int index) =>
          widget.itemBuilder(itemContext, items[index], index),
      childCount: items.length,
    );

    return RefreshIndicator(
      onRefresh: widget.controller.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverPadding(
              padding: widget.padding ?? EdgeInsets.zero,
              sliver: grid == null
                  ? SliverList(delegate: itemDelegate)
                  : SliverGrid(gridDelegate: grid, delegate: itemDelegate),
            ),
            SliverToBoxAdapter(child: _footer(state)),
          ],
        ),
      ),
    );
  }
}
