import 'package:dio/dio.dart';

/// Retries idempotent GET requests on transient failures (timeouts,
/// connection errors, HTTP >= 500) with linear backoff.
///
/// Non-GET methods are **never** retried: a retried POST could double-book a
/// slot. Attach it to [DioApiClient.raw] in the app shell:
///
/// ```dart
/// client.raw.interceptors.add(
///   RetryInterceptor(dio: client.raw, baseDelay: const Duration(milliseconds: 300)),
/// );
/// ```
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxAttempts = 2,
    this.baseDelay = const Duration(milliseconds: 300),
  }) : _dio = dio;

  final Dio _dio;

  /// Total attempts including the original request (1 = no retries).
  final int maxAttempts;

  /// Delay before the first retry; each retry waits `baseDelay * attempt`.
  final Duration baseDelay;

  static const String _attemptKey = 'retry_interceptor_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions options = err.requestOptions;
    final Object? stored = options.extra[_attemptKey];
    final int attempt = stored is int ? stored : 1;

    if (attempt >= maxAttempts || !_isRetryable(err, options)) {
      handler.next(err);
      return;
    }

    options.extra[_attemptKey] = attempt + 1;
    await Future<void>.delayed(baseDelay * attempt);
    try {
      // Re-issue through the same dio, so the full interceptor chain
      // (including this one, tracking the attempt count) runs again.
      final Response<dynamic> response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isRetryable(DioException err, RequestOptions options) {
    if (options.method != 'GET') {
      return false;
    }
    final DioExceptionType type = err.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.connectionError) {
      return true;
    }
    final int? statusCode = err.response?.statusCode;
    return statusCode != null && statusCode >= 500;
  }
}
