import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:commons/commons.dart';

void main() {
  group('RetryInterceptor', () {
    test('retries a 503 GET once and resolves with the retried response',
        () async {
      final _CountingAdapter adapter = _CountingAdapter(failuresBeforeSuccess: 1);
      final Dio dio = _dio(adapter);

      final Response<dynamic> response = await dio.get<dynamic>('/slots');

      expect(adapter.calls, 2);
      expect(response.statusCode, 200);
    });

    test('exhausts attempts when the server keeps failing', () async {
      final _CountingAdapter adapter = _CountingAdapter(failuresBeforeSuccess: 99);
      final Dio dio = _dio(adapter);

      await expectLater(
        () => dio.get<dynamic>('/slots'),
        throwsA(isA<DioException>()),
      );

      // Original + one retry (maxAttempts = 2).
      expect(adapter.calls, 2);
    });

    test('retries on connection errors', () async {
      final _CountingAdapter adapter = _CountingAdapter(
        failuresBeforeSuccess: 1,
        failureType: DioExceptionType.connectionError,
      );
      final Dio dio = _dio(adapter);

      final Response<dynamic> response = await dio.get<dynamic>('/slots');

      expect(adapter.calls, 2);
      expect(response.statusCode, 200);
    });

    test('does not retry 4xx responses', () async {
      final _CountingAdapter adapter = _CountingAdapter(
        failuresBeforeSuccess: 99,
        failureStatus: 404,
      );
      final Dio dio = _dio(adapter);

      await expectLater(
        () => dio.get<dynamic>('/slots'),
        throwsA(isA<DioException>()),
      );

      expect(adapter.calls, 1);
    });

    test('never retries non-GET methods (a POST could double-book)', () async {
      final _CountingAdapter adapter = _CountingAdapter(failuresBeforeSuccess: 99);
      final Dio dio = _dio(adapter);

      await expectLater(
        () => dio.post<dynamic>('/slots/s1/book'),
        throwsA(isA<DioException>()),
      );

      expect(adapter.calls, 1);
    });
  });
}

Dio _dio(_CountingAdapter adapter) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    RetryInterceptor(dio: dio, baseDelay: Duration.zero),
  );
  return dio;
}

/// Fails the first [failuresBeforeSuccess] calls with a DioException, then
/// returns a 200 JSON response.
class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter({
    required this.failuresBeforeSuccess,
    this.failureStatus = 503,
    this.failureType = DioExceptionType.badResponse,
  });

  final int failuresBeforeSuccess;
  final int failureStatus;
  final DioExceptionType failureType;

  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (calls <= failuresBeforeSuccess) {
      final DioException error = failureType == DioExceptionType.badResponse
          ? DioException.badResponse(
              statusCode: failureStatus,
              requestOptions: options,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: failureStatus,
              ),
            )
          : DioException(
              requestOptions: options,
              type: failureType,
            );
      throw error;
    }
    return ResponseBody.fromString(
      '[]',
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
