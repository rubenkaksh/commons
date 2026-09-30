import 'dart:async';

import 'package:flutter/foundation.dart';

/// Fetches one page; return fewer than [pageSize] items to signal the end.
typedef PageFetcher<T> = Future<List<T>> Function(int page, int pageSize);

/// Lifecycle of a [PaginationState].
enum PaginationStatus {
  /// Nothing has been fetched yet.
  initial,

  /// A page request is in flight.
  loading,

  /// The most recent page request completed successfully.
  loaded,

  /// The most recent page request failed; [PaginationState.error] holds why.
  error,
}

/// Immutable snapshot of a paginated list.
///
/// Value-equal by content: two snapshots with the same items, status, end flag,
/// error and page counter compare equal (and hash equal), so listeners can skip
/// a rebuild when nothing observable changed.
@immutable
class PaginationState<T> {
  /// Creates a pagination snapshot.
  const PaginationState({
    this.items = const [],
    this.status = PaginationStatus.initial,
    this.hasReachedEnd = false,
    this.error,
    required this.nextPage,
  });

  /// Items gathered so far, in load order.
  ///
  /// Replaced by an unmodifiable copy whenever a page is appended.
  final List<T> items;

  /// Current lifecycle stage of the list.
  final PaginationStatus status;

  /// Whether the last fetch returned a short page, meaning there is nothing
  /// left to load.
  final bool hasReachedEnd;

  /// Why the most recent fetch failed, or null when the last fetch succeeded.
  final Object? error;

  /// The page number the next fetch will request.
  final int nextPage;

  /// Whether a fetch is currently in flight.
  bool get isLoading => status == PaginationStatus.loading;

  /// Whether loading finished without any items to show.
  bool get isEmpty =>
      status == PaginationStatus.loaded && hasReachedEnd && items.isEmpty;

  /// Returns a copy of this snapshot with the given fields replaced.
  ///
  /// Fields left null keep their current value. [error] is likewise kept unless
  /// a new one is passed or [clearError] is true, which drops a stale error
  /// while leaving every other field untouched.
  PaginationState<T> copyWith({
    List<T>? items,
    PaginationStatus? status,
    bool? hasReachedEnd,
    Object? error,
    bool clearError = false,
    int? nextPage,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      error: error ?? (clearError ? null : this.error),
      nextPage: nextPage ?? this.nextPage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PaginationState<T> &&
        listEquals(items, other.items) &&
        status == other.status &&
        hasReachedEnd == other.hasReachedEnd &&
        error == other.error &&
        nextPage == other.nextPage;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(items),
    status,
    hasReachedEnd,
    error,
    nextPage,
  );
}

/// Drives a [PaginationState] forward by fetching pages on demand.
///
/// Pure [ChangeNotifier]: no bloc/riverpod and no build coupling. Every state
/// transition notifies listeners, and because the state is immutable a widget
/// can rebuild straight from [state].
class PaginationController<T> extends ChangeNotifier {
  /// Creates a controller that pulls [pageSize] items at a time from
  /// [fetchPage], starting at [firstPage].
  PaginationController({
    required this.fetchPage,
    this.pageSize = 20,
    this.firstPage = 1,
  }) : assert(pageSize > 0),
       _state = PaginationState<T>(nextPage: firstPage);

  /// Fetches one page; return fewer than [pageSize] items to signal the end.
  final PageFetcher<T> fetchPage;

  /// How many items to request per page. Must be greater than zero.
  final int pageSize;

  /// The page number loaded by the first fetch and by [refresh].
  final int firstPage;

  /// The current snapshot; always readable, never null.
  PaginationState<T> _state;

  /// The single in-flight load, shared by concurrent [loadNextPage] callers.
  Future<void>? _inFlight;

  /// Bumped by [refresh] so results of superseded loads are dropped.
  int _generation = 0;

  /// Whether [dispose] has run; suppresses further emits.
  bool _disposed = false;

  /// The current snapshot to render from.
  PaginationState<T> get state => _state;

  /// Loads the next page.
  ///
  /// Concurrent calls share ONE in-flight request and return the very same
  /// [Future]; once the end was reached this is a no-op. After an error the
  /// same page is retried, because a failed load leaves the page counter
  /// untouched.
  ///
  /// The shared future is registered before any state is emitted, so a
  /// listener that calls this method synchronously from a notification joins
  /// the running load instead of starting a second one.
  Future<void> loadNextPage() {
    if (_disposed) {
      return Future<void>.value();
    }
    if (_inFlight case final Future<void> pending) {
      return pending;
    }
    if (_state.hasReachedEnd) {
      return Future<void>.value();
    }
    final Completer<void> done = Completer<void>();
    final Future<void> tracked = done.future;
    // Registered BEFORE the first emit, so a listener reacting to any
    // notification of this run sees the pending future and joins it rather
    // than re-entering with a fresh fetch.
    _inFlight = tracked;
    _load(_generation, tracked, done);
    return tracked;
  }

  /// Clears items and loads [firstPage] again.
  ///
  /// Results of any load started before the refresh are discarded when they
  /// arrive. Calling refresh() again while a refresh is loading starts a new
  /// request and discards the earlier one (by design: the latest refresh
  /// wins).
  Future<void> refresh() {
    if (_disposed) {
      return Future<void>.value();
    }
    _generation++;
    _inFlight = null;
    _emit(PaginationState<T>(nextPage: firstPage));
    return loadNextPage();
  }

  /// Fetches [page] and folds the result into the state, or records the error.
  ///
  /// [gen] is the generation captured when the run started; a result from a
  /// superseded run is dropped. [tracked] is the future published in
  /// [_inFlight], cleared before the terminal emit so listeners notified of
  /// the final state may start the next load straight away. [done] completes
  /// the caller's future once the run is over.
  Future<void> _load(
    int gen,
    Future<void> tracked,
    Completer<void> done,
  ) async {
    final int page = _state.nextPage;
    _emit(_state.copyWith(status: PaginationStatus.loading, clearError: true));
    try {
      final List<T> batch = await fetchPage(page, pageSize);
      if (_disposed || gen != _generation) {
        return;
      }
      if (identical(_inFlight, tracked)) {
        _inFlight = null;
      }
      _emit(
        _state.copyWith(
          items: List<T>.unmodifiable(<T>[..._state.items, ...batch]),
          status: PaginationStatus.loaded,
          hasReachedEnd: batch.length < pageSize,
          nextPage: page + 1,
        ),
      );
    } on Object catch (e) {
      if (_disposed || gen != _generation) {
        return;
      }
      if (identical(_inFlight, tracked)) {
        _inFlight = null;
      }
      _emit(_state.copyWith(status: PaginationStatus.error, error: e));
    } finally {
      if (!done.isCompleted) {
        done.complete();
      }
    }
  }

  /// Publishes [next] unless the controller was disposed.
  void _emit(PaginationState<T> next) {
    if (_disposed) {
      return;
    }
    _state = next;
    notifyListeners();
  }

  /// Marks the controller disposed so late results are dropped silently.
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
