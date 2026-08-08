import 'package:dio/dio.dart';

import 'app_exception.dart';

class DioApiClient {
  DioApiClient({required String baseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  Dio get raw => _dio;

  void setBearerToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Maps a [DioException] into a typed [AppException] with a user-facing
  /// message.
  ///
  /// - timeouts → [AppTimeoutException]
  /// - connection failures → [AppOfflineException]
  /// - HTTP 4xx → [AppClientException] (prefers the server's own `message`
  ///   field when the error body carries one)
  /// - HTTP 5xx → [AppServerException]
  /// - anything else → [AppUnexpectedException]
  ///
  /// Every method on this client already converts [DioException]s at the
  /// boundary, so callers normally never see a raw dio error.
  AppException mapDioException(DioException e) {
    final DioExceptionType type = e.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout) {
      return const AppTimeoutException(
        'The server took too long to respond. Please try again.',
      );
    }
    if (type == DioExceptionType.connectionError) {
      return const AppOfflineException(
        'You appear to be offline. Check your connection and try again.',
      );
    }

    final int? statusCode = e.response?.statusCode;
    if (statusCode != null) {
      final String? serverMessage = _serverMessage(e.response?.data);
      if (statusCode >= 500) {
        return AppServerException(
          serverMessage ?? 'Server error (HTTP $statusCode). Please try again later.',
          statusCode: statusCode,
        );
      }
      return AppClientException(
        serverMessage ?? 'Request failed (HTTP $statusCode).',
        statusCode: statusCode,
      );
    }

    return const AppUnexpectedException('Something went wrong. Please try again.');
  }

  static String? _serverMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final Object? message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(path);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
    return _expectObject(response.data);
  }

  /// GET a JSON array of objects, e.g. list endpoints.
  Future<List<Map<String, dynamic>>> getJsonList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      // Re-thrown typed so callers can distinguish offline/timeout/server
      // failures (a blanket catch here would hide the dio error type).
      throw mapDioException(e);
    }
    final Object? data = response.data;
    if (data is List) {
      final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
      for (final Object? item in data) {
        if (item is Map<String, dynamic>) {
          items.add(item);
        } else {
          throw const ApiClientException('Expected JSON array of objects.');
        }
      }
      return items;
    }
    throw const ApiClientException('Expected JSON array response.');
  }

  /// POST a JSON body and return the JSON object response.
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        path,
        data: body,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
    return _expectObject(response.data);
  }

  Map<String, dynamic> _expectObject(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ApiClientException('Expected JSON object response.');
  }
}

class ApiClientException implements Exception {
  const ApiClientException(this.message);

  final String message;
}
