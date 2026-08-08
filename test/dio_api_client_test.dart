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

    test('getJson maps non-2xx responses to a typed AppException', () async {
      final Dio dio = Dio()
        ..httpClientAdapter = _RecordingJsonAdapter(
          (RequestOptions options) async => ResponseBody.fromString(
            jsonEncode(<String, dynamic>{'message': 'Unauthorized'}),
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

      await expectLater(
        () => client.getJson('/slots'),
        throwsA(
          isA<AppClientException>().having(
            (AppClientException e) => e.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
    });

    test('maps HTTP 500 to AppServerException', () async {
      final Dio dio = Dio()
        ..httpClientAdapter = _RecordingJsonAdapter(
          (RequestOptions options) async => ResponseBody.fromString(
            jsonEncode(<String, dynamic>{'message': 'Internal Server Error'}),
            500,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          ),
        );
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      await expectLater(
        () => client.getJsonList('/slots'),
        throwsA(isA<AppServerException>()),
      );
    });

    test('prefers the server message on 4xx responses', () async {
      final Dio dio = Dio()
        ..httpClientAdapter = _RecordingJsonAdapter(
          (RequestOptions options) async => ResponseBody.fromString(
            jsonEncode(<String, dynamic>{
              'message': 'Phone number already registered.',
            }),
            409,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          ),
        );
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      await expectLater(
        () => client.getJson('/auth/register'),
        throwsA(
          isA<AppClientException>().having(
            (AppClientException e) => e.message,
            'message',
            'Phone number already registered.',
          ),
        ),
      );
    });

    test('maps timeouts to AppTimeoutException', () async {
      final Dio dio = Dio()
        ..httpClientAdapter = _ThrowingDioAdapter(
          DioException(
            requestOptions: RequestOptions(path: '/slots'),
            type: DioExceptionType.receiveTimeout,
          ),
        );
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      await expectLater(
        () => client.getJsonList('/slots'),
        throwsA(isA<AppTimeoutException>()),
      );
    });

    test('maps connection errors to AppOfflineException', () async {
      final Dio dio = Dio()
        ..httpClientAdapter = _ThrowingDioAdapter(
          DioException(
            requestOptions: RequestOptions(path: '/slots'),
            type: DioExceptionType.connectionError,
          ),
        );
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      await expectLater(
        () => client.getJson('/slots'),
        throwsA(isA<AppOfflineException>()),
      );
    });

    test('maps unknown errors to AppUnexpectedException', () async {
      final Dio dio = Dio()
        ..httpClientAdapter = _ThrowingDioAdapter(
          DioException(
            requestOptions: RequestOptions(path: '/slots'),
            type: DioExceptionType.unknown,
          ),
        );
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      await expectLater(
        () => client.getJsonList('/slots'),
        throwsA(isA<AppUnexpectedException>()),
      );
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

/// Adapter that always throws the given [DioException] (dio propagates
/// exceptions thrown by the adapter unchanged, so this simulates timeouts,
/// connection failures and unknown errors).
class _ThrowingDioAdapter implements HttpClientAdapter {
  _ThrowingDioAdapter(this.error);

  final DioException error;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw error;
  }

  @override
  void close({bool force = false}) {}
}
