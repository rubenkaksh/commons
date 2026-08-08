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
