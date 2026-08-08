import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:commons/commons.dart';

void main() {
  group('DioApiClient', () {
    test('sets and clears bearer token header', () {
      final Dio dio = Dio();
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      client.setBearerToken('abc123');
      expect(dio.options.headers['Authorization'], 'Bearer abc123');

      client.setBearerToken(null);
      expect(dio.options.headers.containsKey('Authorization'), isFalse);
    });

    test('returns JSON object responses', () async {
      final Dio dio = Dio()
        ..httpClientAdapter = _StaticJsonAdapter(<String, dynamic>{
          'status': 'ok',
          'healthy': true,
        });
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      final Map<String, dynamic> json = await client.getJson('/status');

      expect(json['status'], 'ok');
      expect(json['healthy'], isTrue);
    });

    test(
      'getJsonList sends query parameters and returns a list of objects',
      () async {
        final _RecordingJsonAdapter adapter = _RecordingJsonAdapter((
          RequestOptions options,
        ) async {
          expect(options.path, '/slots');
          expect(options.queryParameters['turfId'], 'turf-1');
          expect(options.queryParameters['date'], '2026-07-31');
          return _jsonResponse(<dynamic>[
            <String, dynamic>{'id': 's1'},
            <String, dynamic>{'id': 's2'},
          ]);
        });
        final Dio dio = Dio()..httpClientAdapter = adapter;
        final DioApiClient client = DioApiClient(
          baseUrl: 'https://example.test',
          dio: dio,
        );

        final List<Map<String, dynamic>> items = await client.getJsonList(
          '/slots',
          queryParameters: <String, dynamic>{
            'turfId': 'turf-1',
            'date': '2026-07-31',
          },
        );

        expect(items, hasLength(2));
        expect(items.first['id'], 's1');
      },
    );

    test(
      'getJsonList throws ApiClientException when response is not a list',
      () async {
        final Dio dio = Dio()
          ..httpClientAdapter = _StaticJsonAdapter(<String, dynamic>{
            'status': 'ok',
          });
        final DioApiClient client = DioApiClient(
          baseUrl: 'https://example.test',
          dio: dio,
        );

        expect(
          () => client.getJsonList('/slots'),
          throwsA(isA<ApiClientException>()),
        );
      },
    );

    test(
      'postJson sends the body and returns the JSON object response',
      () async {
        final _RecordingJsonAdapter adapter = _RecordingJsonAdapter((
          RequestOptions options,
        ) async {
          expect(options.method, 'POST');
          expect(options.path, '/slots/s1/book');
          expect(options.data, <String, dynamic>{
            'customerPhone': '9876543210',
          });
          return _jsonResponse(<String, dynamic>{
            'booking': <String, dynamic>{'id': 'b1'},
            'slot': <String, dynamic>{'id': 's1', 'status': 'booked'},
          });
        });
        final Dio dio = Dio()..httpClientAdapter = adapter;
        final DioApiClient client = DioApiClient(
          baseUrl: 'https://example.test',
          dio: dio,
        );

        final Map<String, dynamic> json = await client.postJson(
          '/slots/s1/book',
          body: <String, dynamic>{'customerPhone': '9876543210'},
        );

        expect(json['booking'], <String, dynamic>{'id': 'b1'});
        expect(json['slot'], <String, dynamic>{'id': 's1', 'status': 'booked'});
      },
    );

    test('getJson rethrows DioException on non-2xx responses', () async {
      final Dio dio = Dio()
        ..httpClientAdapter = _RecordingJsonAdapter(
          (RequestOptions options) async => ResponseBody.fromString(
            'Unauthorized',
            401,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          ),
        );
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      expect(() => client.getJson('/slots'), throwsA(isA<DioException>()));
    });
  });

  group('DioApiClient GET cache', () {
    test('serves a repeated getJsonList within the TTL from memory', () async {
      final _CountingJsonAdapter adapter = _CountingJsonAdapter();
      final Dio dio = Dio()..httpClientAdapter = adapter;
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      final List<Map<String, dynamic>> first = await client.getJsonList(
        '/slots',
        queryParameters: <String, dynamic>{
          'turfId': 'turf-1',
          'date': '2026-08-08',
        },
      );
      final List<Map<String, dynamic>> second = await client.getJsonList(
        '/slots',
        queryParameters: <String, dynamic>{
          'turfId': 'turf-1',
          'date': '2026-08-08',
        },
      );

      expect(adapter.calls, 1);
      expect(first, hasLength(1));
      expect(second, hasLength(1));
    });

    test('keys the cache by query parameters (different date re-fetches)',
        () async {
      final _CountingJsonAdapter adapter = _CountingJsonAdapter();
      final Dio dio = Dio()..httpClientAdapter = adapter;
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      await client.getJsonList(
        '/slots',
        queryParameters: <String, dynamic>{'date': '2026-08-07'},
      );
      await client.getJsonList(
        '/slots',
        queryParameters: <String, dynamic>{'date': '2026-08-08'},
      );

      expect(adapter.calls, 2);
    });

    test('caches getJson object responses too', () async {
      final _CountingJsonAdapter adapter = _CountingJsonAdapter(
        body: (RequestOptions options) => <String, dynamic>{'id': 't1'},
      );
      final Dio dio = Dio()..httpClientAdapter = adapter;
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      await client.getJson('/turfs/turf-1');
      await client.getJson('/turfs/turf-1');

      expect(adapter.calls, 1);
    });

    test('re-fetches once the entry expires (TTL elapses)', () async {
      final _CountingJsonAdapter adapter = _CountingJsonAdapter();
      final Dio dio = Dio()..httpClientAdapter = adapter;
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
        // Zero TTL: every entry is already expired at the moment it is read.
        getCacheTtl: Duration.zero,
      );

      await client.getJsonList('/slots');
      await client.getJsonList('/slots');

      expect(adapter.calls, 2);
    });

    test('does not cache failures (a later success still fetches)', () async {
      int calls = 0;
      final Dio dio = Dio()
        ..httpClientAdapter = _RecordingJsonAdapter(
          (RequestOptions options) async {
            calls++;
            if (calls == 1) {
              throw DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 503,
                ),
              );
            }
            return _jsonResponse(<dynamic>[<String, dynamic>{'id': 's1'}]);
          },
        );
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      await expectLater(
        () => client.getJsonList('/slots'),
        throwsA(isA<DioException>()),
      );
      final List<Map<String, dynamic>> retried = await client.getJsonList(
        '/slots',
      );

      expect(calls, 2);
      expect(retried, hasLength(1));
    });

    test('a successful postJson flushes the cache (booking is visible now)',
        () async {
      final _CountingJsonAdapter adapter = _CountingJsonAdapter(
        body: (RequestOptions options) => options.method == 'POST'
            ? <String, dynamic>{'ok': true}
            : <dynamic>[<String, dynamic>{'id': 's1'}],
      );
      final Dio dio = Dio()..httpClientAdapter = adapter;
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      // Pre-booking slots GET is cached.
      await client.getJsonList(
        '/slots',
        queryParameters: <String, dynamic>{'date': '2026-08-08'},
      );
      // Booking mutates server state...
      await client.postJson(
        '/slots/s1/book',
        body: <String, dynamic>{'customerPhone': '9876543210'},
      );
      // ...so the next slots GET must hit the network again (3 calls total:
      // pre-booking GET, the POST itself, and the post-booking GET).
      await client.getJsonList(
        '/slots',
        queryParameters: <String, dynamic>{'date': '2026-08-08'},
      );

      expect(adapter.calls, 3);
    });

    test('setBearerToken flushes the cache (account boundary)', () async {
      final _CountingJsonAdapter adapter = _CountingJsonAdapter();
      final Dio dio = Dio()..httpClientAdapter = adapter;
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      await client.getJsonList('/slots');
      client.setBearerToken('new-token');
      await client.getJsonList('/slots');

      expect(adapter.calls, 2);
    });
  });

  group('DioApiClient.mapDioException', () {
    final DioApiClient client = DioApiClient(baseUrl: 'https://example.test');

    DioException badResponse(int statusCode, Object? data) {
      final RequestOptions options = RequestOptions(path: '/slots');
      return DioException.badResponse(
        statusCode: statusCode,
        requestOptions: options,
        response: Response<Object?>(
          requestOptions: options,
          statusCode: statusCode,
          data: data,
        ),
      );
    }

    test('maps 4xx to AppClientException preferring the server message', () {
      final AppException mapped = client.mapDioException(
        badResponse(409, <String, dynamic>{
          'message': 'Phone number already registered.',
        }),
      );

      expect(
        mapped,
        isA<AppClientException>()
            .having(
              (AppClientException e) => e.statusCode,
              'statusCode',
              409,
            )
            .having(
              (AppClientException e) => e.message,
              'message',
              'Phone number already registered.',
            ),
      );
    });

    test('maps 4xx without a server message to a generic message', () {
      final AppException mapped = client.mapDioException(badResponse(401, null));

      expect(
        mapped,
        isA<AppClientException>().having(
          (AppClientException e) => e.message,
          'message',
          'Request failed (HTTP 401).',
        ),
      );
    });

    test('maps 5xx to AppServerException', () {
      final AppException mapped = client.mapDioException(badResponse(503, null));

      expect(
        mapped,
        isA<AppServerException>()
            .having((AppServerException e) => e.statusCode, 'statusCode', 503)
            .having(
              (AppServerException e) => e.message,
              'message',
              contains('503'),
            ),
      );
    });

    test('maps timeouts to AppTimeoutException', () {
      final AppException mapped = client.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/slots'),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(mapped, isA<AppTimeoutException>());
    });

    test('maps connection errors to AppOfflineException', () {
      final AppException mapped = client.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/slots'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(mapped, isA<AppOfflineException>());
    });

    test('maps unknown errors to AppUnexpectedException', () {
      final AppException mapped = client.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/slots'),
          type: DioExceptionType.unknown,
        ),
      );

      expect(mapped, isA<AppUnexpectedException>());
    });
  });
}

ResponseBody _jsonResponse(Object? body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

/// Adapter that lets each test decide the response for the request and keeps
/// the last [RequestOptions] for assertions.
class _RecordingJsonAdapter implements HttpClientAdapter {
  _RecordingJsonAdapter(this.respond);

  final Future<ResponseBody> Function(RequestOptions options) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

/// Adapter that returns a fresh 200 JSON response per call (a list by
/// default, or whatever [body] builds) and counts calls, so tests can assert
/// the cache prevented a second network hit.
class _CountingJsonAdapter implements HttpClientAdapter {
  _CountingJsonAdapter({this.body});

  /// Builds the response payload per request; defaults to a one-item list.
  final Object? Function(RequestOptions options)? body;

  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    final Object payload =
        body?.call(options) ?? <dynamic>[<String, dynamic>{'id': 's1'}];
    return _jsonResponse(payload);
  }

  @override
  void close({bool force = false}) {}
}

class _StaticJsonAdapter implements HttpClientAdapter {
  const _StaticJsonAdapter(this.body);

  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
