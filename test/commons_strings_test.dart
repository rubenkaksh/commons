import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/commons.dart';

class _Nepali extends CommonsStrings {
  const _Nepali();

  @override
  String get retry => 'पुनः प्रयास';
  @override
  String get genericError => 'केही गडबड भयो';
  @override
  String get cancel => 'रद्द';
  @override
  String get showPassword => 'देखाउनुहोस्';
  @override
  String get timeoutError => 'समय सकियो';
}

Widget _host(Widget child, {CommonsStrings? strings}) {
  final Widget body = Scaffold(body: child);
  return MaterialApp(
    home: strings == null ? body : CommonsStringsScope(strings: strings, child: body),
  );
}

void main() {
  group('CommonsStrings defaults (English)', () {
    const CommonsStrings s = CommonsStrings();

    test('labels', () {
      expect(s.retry, 'Retry');
      expect(s.cancel, 'Cancel');
      expect(s.genericError, 'Something went wrong.');
      expect(s.showPassword, 'Show password');
      expect(s.hidePassword, 'Hide password');
    });

    test('network messages keep the pre-P5 wording', () {
      expect(s.timeoutError, 'The server took too long to respond. Please try again.');
      expect(s.offlineError, 'You appear to be offline. Check your connection and try again.');
      expect(s.unexpectedError, 'Something went wrong. Please try again.');
      expect(s.clientError(401), 'Request failed (HTTP 401).');
      expect(s.serverError(503), 'Server error (HTTP 503). Please try again later.');
    });
  });

  group('CommonsStrings.of', () {
    testWidgets('falls back to English defaults without a scope', (WidgetTester tester) async {
      late CommonsStrings found;
      await tester.pumpWidget(_host(Builder(builder: (BuildContext c) {
        found = CommonsStrings.of(c);
        return const SizedBox();
      })));
      expect(found.retry, 'Retry');
    });

    testWidgets('returns the scoped strings', (WidgetTester tester) async {
      late CommonsStrings found;
      await tester.pumpWidget(_host(Builder(builder: (BuildContext c) {
        found = CommonsStrings.of(c);
        return const SizedBox();
      }), strings: const _Nepali()));
      expect(found, isA<_Nepali>());
    });
  });

  group('widgets read the scope', () {
    testWidgets('ErrorView retry label', (WidgetTester tester) async {
      await tester.pumpWidget(_host(ErrorView(message: 'x', onRetry: () {}), strings: const _Nepali()));
      expect(find.text('पुनः प्रयास'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('StateSwitcher default error message', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        const StateSwitcher(state: LoadState.error, data: SizedBox()),
        strings: const _Nepali(),
      ));
      expect(find.text('केही गडबड भयो'), findsOneWidget);
    });

    testWidgets('FormBottomSheet default cancel label; explicit label still wins', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        FormBottomSheet(title: 't', body: const SizedBox(), confirmLabel: 'ok', onConfirm: () {}),
        strings: const _Nepali(),
      ));
      expect(find.text('रद्द'), findsOneWidget);

      await tester.pumpWidget(_host(
        FormBottomSheet(title: 't', body: const SizedBox(), confirmLabel: 'ok', onConfirm: () {}, cancelLabel: 'Close'),
        strings: const _Nepali(),
      ));
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('PasswordInput visibility tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const PasswordInput(label: 'p'), strings: const _Nepali()));
      expect(find.byTooltip('देखाउनुहोस्'), findsOneWidget);
    });
  });

  test('DioApiClient maps with injected strings', () {
    final DioApiClient client = DioApiClient(
      baseUrl: 'https://example.test',
      dio: Dio(),
      strings: const _Nepali(),
    );
    final AppException mapped = client.mapDioException(
      DioException(requestOptions: RequestOptions(path: '/x'), type: DioExceptionType.receiveTimeout),
    );
    expect(mapped.message, 'समय सकियो');
  });
}
