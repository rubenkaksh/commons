import 'dart:async';

import 'package:commons/src/widgets/pagination_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [PageFetcher] that records every (page, pageSize) call and parks each
/// returned future on a [Completer], so the test decides when (and how) each
/// fetch resolves.
class FakePageFetcher {
  final List<(int, int)> calls = <(int, int)>[];
  final List<Completer<List<int>>> completers = <Completer<List<int>>>[];

  Future<List<int>> call(int page, int pageSize) {
    final Completer<List<int>> completer = Completer<List<int>>();
    completers.add(completer);
    calls.add((page, pageSize));
    return completer.future;
  }
}

PaginationController<int> makeController(
  FakePageFetcher fake, {
  int pageSize = 2,
  int firstPage = 1,
}) {
  return PaginationController<int>(
    fetchPage: fake.call,
    pageSize: pageSize,
    firstPage: firstPage,
  );
}

void main() {
  test('1. initial state: empty items, initial status, nextPage == firstPage', () {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);

    expect(controller.state.items, isEmpty);
    expect(controller.state.status, PaginationStatus.initial);
    expect(controller.state.nextPage, controller.firstPage);
    expect(controller.state.hasReachedEnd, isFalse);
    expect(controller.state.isLoading, isFalse);
    expect(fake.calls, isEmpty);

    controller.dispose();
  });

  test('2. loadNextPage fetches page 1 with pageSize; full page keeps end false', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);

    final Future<void> first = controller.loadNextPage();
    expect(fake.calls, <(int, int)>[(1, 2)]);
    expect(controller.state.status, PaginationStatus.loading);
    expect(controller.state.isLoading, isTrue);

    fake.completers[0].complete(<int>[1, 2]);
    await first;

    expect(controller.state.status, PaginationStatus.loaded);
    expect(controller.state.items, <int>[1, 2]);
    expect(controller.state.nextPage, 2);
    expect(controller.state.hasReachedEnd, isFalse);

    controller.dispose();
  });

  test('3. a short page sets hasReachedEnd and blocks any further fetch', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);

    final Future<void> first = controller.loadNextPage();
    fake.completers[0].complete(<int>[1]);
    await first;

    expect(controller.state.hasReachedEnd, isTrue);
    expect(controller.state.items, <int>[1]);
    expect(controller.state.status, PaginationStatus.loaded);
    expect(controller.state.nextPage, 2);

    final Future<void> second = controller.loadNextPage();
    await second;

    expect(fake.calls, <(int, int)>[(1, 2)], reason: 'end reached: no new fetch');
    expect(controller.state.items, <int>[1]);
    expect(controller.state.nextPage, 2);

    controller.dispose();
  });

  test('4. dedupe: concurrent loadNextPage calls share one fetch and one future', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);

    final Future<void> a = controller.loadNextPage();
    final Future<void> b = controller.loadNextPage();

    expect(fake.calls, <(int, int)>[(1, 2)], reason: 'exactly one fetch');
    expect(identical(a, b), isTrue, reason: 'both callers get the same Future');

    fake.completers[0].complete(<int>[1, 2]);
    await a;
    await b;

    expect(fake.calls, <(int, int)>[(1, 2)], reason: 'still exactly one fetch');
    expect(controller.state.items, <int>[1, 2]);
    expect(controller.state.status, PaginationStatus.loaded);

    controller.dispose();
  });

  test('5. error: keeps items/nextPage, records StateError, then retries same page', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);

    final Future<void> failing = controller.loadNextPage();
    final StateError boom = StateError('boom');
    fake.completers[0].completeError(boom);
    await failing;

    expect(controller.state.status, PaginationStatus.error);
    expect(controller.state.error, same(boom));
    expect(controller.state.items, isEmpty);
    expect(controller.state.nextPage, 1, reason: 'failed page must not advance');

    final Future<void> retry = controller.loadNextPage();
    expect(
      fake.calls,
      <(int, int)>[(1, 2), (1, 2)],
      reason: 'retry must request the SAME page number',
    );

    fake.completers[1].complete(<int>[1, 2]);
    await retry;

    expect(controller.state.status, PaginationStatus.loaded);
    expect(controller.state.error, isNull, reason: 'stale error cleared on success');
    expect(controller.state.items, <int>[1, 2]);
    expect(controller.state.nextPage, 2);

    controller.dispose();
  });

  test('6. refresh discards the stale in-flight load when it lands later', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);

    // Load A: page 1, left pending.
    final Future<void> loadA = controller.loadNextPage();
    expect(fake.calls, <(int, int)>[(1, 2)]);

    // refresh() resets the state and starts load B for page 1 again.
    final Future<void> refreshLoad = controller.refresh();
    expect(fake.calls, <(int, int)>[(1, 2), (1, 2)]);
    expect(controller.state.items, isEmpty, reason: 'refresh cleared items');
    expect(controller.state.status, PaginationStatus.loading);

    fake.completers[1].complete(<int>[10, 11]);
    await refreshLoad;
    expect(controller.state.items, <int>[10, 11]);

    // The superseded load A arrives late and must be dropped.
    fake.completers[0].complete(<int>[1, 2]);
    await loadA;

    expect(controller.state.items, <int>[10, 11], reason: 'stale A ignored');
    expect(controller.state.status, PaginationStatus.loaded);
    expect(controller.state.nextPage, 2);
    expect(fake.calls, <(int, int)>[(1, 2), (1, 2)], reason: 'no extra fetches');

    controller.dispose();
  });

  test('7. refresh resets items and loads firstPage again', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);

    final Future<void> first = controller.loadNextPage();
    fake.completers[0].complete(<int>[1, 2]);
    await first;
    expect(controller.state.items, <int>[1, 2]);
    expect(controller.state.nextPage, 2);

    final Future<void> refreshed = controller.refresh();
    expect(controller.state.items, isEmpty, reason: 'items cleared synchronously');
    expect(fake.calls.last, (1, 2), reason: 'firstPage requested again');

    fake.completers[1].complete(<int>[7, 8]);
    await refreshed;

    expect(controller.state.status, PaginationStatus.loaded);
    expect(controller.state.items, <int>[7, 8], reason: 'replaced, not appended');
    expect(controller.state.nextPage, 2);

    controller.dispose();
  });

  test('8. no notification (and no exception) after dispose', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);
    final List<PaginationStatus> seen = <PaginationStatus>[];
    controller.addListener(() => seen.add(controller.state.status));

    final Future<void> load = controller.loadNextPage();
    expect(seen, <PaginationStatus>[PaginationStatus.loading]);
    final int notifiedBeforeDispose = seen.length;

    controller.dispose();

    fake.completers[0].complete(<int>[1, 2]);
    await load; // must not throw: late result is dropped silently

    expect(seen.length, notifiedBeforeDispose, reason: 'no listener call after dispose');
    expect(seen, isNot(contains(PaginationStatus.loaded)));
  });

  test('9. PaginationState value equality and copyWith(clearError: true)', () {
    final PaginationState<int> a = PaginationState<int>(
      items: <int>[1, 2],
      status: PaginationStatus.loaded,
      nextPage: 2,
    );
    final PaginationState<int> b = PaginationState<int>(
      items: <int>[1, 2], // equal content, different List instance
      status: PaginationStatus.loaded,
      nextPage: 2,
    );

    expect(identical(a.items, b.items), isFalse);
    expect(a, b);
    expect(a.hashCode, b.hashCode);

    final PaginationState<int> different = PaginationState<int>(
      items: <int>[1, 3],
      status: PaginationStatus.loaded,
      nextPage: 2,
    );
    expect(a == different, isFalse);

    final PaginationState<int> withError = a.copyWith(
      status: PaginationStatus.error,
      error: StateError('boom'),
    );
    expect(withError.error, isNotNull);
    expect(withError.copyWith(nextPage: 3).error, isNotNull,
        reason: 'error kept unless cleared');

    final PaginationState<int> cleared = withError.copyWith(clearError: true);
    expect(cleared.error, isNull, reason: 'clearError drops the error');
    expect(cleared.status, PaginationStatus.error, reason: 'other fields untouched');
    expect(cleared.items, a.items);
    expect(cleared.nextPage, a.nextPage);
  });

  test('10. listeners are notified on loading and on loaded', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);
    final List<PaginationStatus> seen = <PaginationStatus>[];
    controller.addListener(() => seen.add(controller.state.status));

    final Future<void> load = controller.loadNextPage();
    expect(seen, <PaginationStatus>[PaginationStatus.loading]);

    fake.completers[0].complete(<int>[1, 2]);
    await load;

    expect(seen, <PaginationStatus>[
      PaginationStatus.loading,
      PaginationStatus.loaded,
    ]);

    controller.dispose();
  });

  test('11. (a) re-entrancy on loading: listener re-entering loadNextPage joins the run', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);
    controller.addListener(() {
      if (controller.state.status == PaginationStatus.loading) {
        controller.loadNextPage();
      }
    });

    final Future<void> load = controller.loadNextPage();
    expect(fake.calls, <(int, int)>[(1, 2)],
        reason: 're-entrant call joined the pending load: no second fetch');

    fake.completers[0].complete(<int>[1, 2]);
    await load;
    await Future<void>.delayed(Duration.zero); // flush any late re-entry

    expect(fake.calls, <(int, int)>[(1, 2)],
        reason: 'exactly ONE fetch for the whole run');
    expect(controller.state.status, PaginationStatus.loaded);
    expect(controller.state.items, <int>[1, 2]);

    controller.dispose();
  });

  test('12. (b) re-entrancy on error: listener starts the retry from the terminal emit', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);
    bool fired = false;
    controller.addListener(() {
      if (!fired && controller.state.status == PaginationStatus.error) {
        fired = true;
        controller.loadNextPage();
      }
    });

    final Future<void> failing = controller.loadNextPage();
    fake.completers[0].completeError(StateError('boom'));
    await failing;
    // Only pump microtasks: the retry must already be running from the emit.
    await Future<void>.delayed(Duration.zero);

    expect(fake.calls, <(int, int)>[(1, 2), (1, 2)],
        reason: 'SECOND fetch for page 1 started immediately from the error emit');
    expect(controller.state.status, PaginationStatus.loading,
        reason: 'the retried load is in flight');
    expect(controller.state.nextPage, 1, reason: 'failed page still not advanced');
    expect(fired, isTrue, reason: 'listener fired exactly once');

    controller.dispose();
  });

  test('13. (c) stale load: after superseded A lands, loadNextPage joins pending B', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);

    // Load A pending, then refresh() starts load B (also pending).
    final Future<void> loadA = controller.loadNextPage();
    // The stale load still completes its own future once it lands.
    expect(loadA, completes);
    expect(fake.calls, <(int, int)>[(1, 2)]);
    final Future<void> loadB = controller.refresh();
    expect(fake.calls, <(int, int)>[(1, 2), (1, 2)]);

    // A (stale, older generation) completes FIRST and must be discarded.
    fake.completers[0].complete(<int>[1, 2]);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.items, isEmpty, reason: 'stale A dropped');

    final Future<void> joined = controller.loadNextPage();
    expect(identical(joined, loadB), isTrue,
        reason: 'returns the SAME future as the still-pending refresh load');
    expect(fake.calls, <(int, int)>[(1, 2), (1, 2)],
        reason: 'joining B must NOT add a fetch call');

    fake.completers[1].complete(<int>[10, 11]);
    await joined;

    expect(controller.state.items, <int>[10, 11], reason: "B's result wins");
    expect(fake.calls, <(int, int)>[(1, 2), (1, 2)], reason: 'still only two fetches');

    controller.dispose();
  });

  test('14. (d) after dispose: loadNextPage() and refresh() make NO fetch calls', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);

    controller.dispose();

    final Future<void> afterLoad = controller.loadNextPage();
    final Future<void> afterRefresh = controller.refresh();
    await afterLoad;
    await afterRefresh;
    await Future<void>.delayed(Duration.zero);

    expect(fake.calls, <(int, int)>[], reason: 'disposed controller must not fetch');
    expect(controller.state.status, PaginationStatus.initial);
    expect(controller.state.items, isEmpty);
  });

  test('15. (e) dedupe after error: two concurrent retries produce exactly one new fetch', () async {
    final FakePageFetcher fake = FakePageFetcher();
    final PaginationController<int> controller = makeController(fake);

    final Future<void> first = controller.loadNextPage();
    fake.completers[0].completeError(StateError('boom'));
    await first;
    expect(controller.state.status, PaginationStatus.error);
    expect(fake.calls, <(int, int)>[(1, 2)], reason: 'baseline: one failed fetch');

    final Future<void> retryA = controller.loadNextPage();
    final Future<void> retryB = controller.loadNextPage();

    expect(fake.calls, <(int, int)>[(1, 2), (1, 2)],
        reason: 'exactly ONE new fetch for the concurrent retries');
    expect(identical(retryA, retryB), isTrue,
        reason: 'both retryers share the same future');

    fake.completers[1].complete(<int>[1, 2]);
    await retryA;
    await retryB;

    expect(controller.state.status, PaginationStatus.loaded);
    expect(controller.state.items, <int>[1, 2]);

    controller.dispose();
  });
}
