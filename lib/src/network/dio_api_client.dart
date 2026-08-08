import 'package:dio/dio.dart';

import 'app_exception.dart';

class DioApiClient {
  DioApiClient({
    required String baseUrl,
    Dio? dio,
    this.getCacheTtl = const Duration(seconds: 30),
  }) : _dio =
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

  /// How long successful GET responses stay in the in-memory cache. Kept
  /// short on purpose: the cache only serves fast re-selects (e.g. switching
  /// booking dates back and forth), it never substitutes a fresh fetch for
  /// long.
  final Duration getCacheTtl;

  final Map<String, _CachedGetEntry> _getCache = <String, _CachedGetEntry>{};

  Dio get raw => _dio;

  void setBearerToken(String? token) {
    // Any token change is an account boundary: drop cached responses so a
    // different user never sees the previous user's data.
    _getCache.clear();
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Maps a [DioException] into a typed [AppException] with a user-facing
  /// message.
  ///
  /// Services catch `DioException` at their own boundary and rethrow the
  /// mapped value, e.g.:
  ///
  /// ```dart
  /// try {
  ///   return await _apiClient.getJsonList('/slots');
  /// } on DioException catch (e) {
  ///   throw _apiClient.mapDioException(e);
  /// }
  /// ```
  ///
  /// - timeouts → [AppTimeoutException]
  /// - connection failures → [AppOfflineException]
  /// - HTTP 4xx → [AppClientException] (prefers the server's own `message`
  ///   field when the error body carries one)
  /// - HTTP 5xx → [AppServerException]
  /// - anything else → [AppUnexpectedException]
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
    final String key = _key(path);
    final Object? cached = _cachedGet(key);
    if (cached != null) {
      return _expectObject(cached);
    }
    final Response<dynamic> response = await _dio.get<dynamic>(path);
    _cachePut(key, response.data);
    return _expectObject(response.data);
  }

  /// GET a JSON array of objects, e.g. list endpoints.
  ///
  /// Network/HTTP failures propagate as raw [DioException]s (services map
  /// them via [mapDioException]); shape failures throw [ApiClientException].
  ///
  /// Successful responses are cached for [getCacheTtl], keyed by path +
  /// query parameters — re-selecting the same date is served from memory
  /// instead of hitting the network again. A successful [postJson] or any
  /// [setBearerToken] call invalidates the cache, so a booking or an account
  /// change is always reflected immediately.
  Future<List<Map<String, dynamic>>> getJsonList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final String key = _key(path, queryParameters);
    final Object? cached = _cachedGet(key);
    if (cached != null) {
      return _expectObjectList(cached);
    }
    final Response<dynamic> response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
    );
    _cachePut(key, response.data);
    return _expectObjectList(response.data);
  }

  /// POST a JSON body and return the JSON object response.
  ///
  /// A successful POST mutates server state (e.g. booking a slot), so it
  /// flushes the GET cache: the just-created booking must not stay invisible
  /// behind a cached pre-booking response for the rest of the TTL.
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      path,
      data: body,
    );
    _getCache.clear();
    return _expectObject(response.data);
  }

  /// Stable in-memory cache key for a GET: path + sorted query parameters.
  static String _key(String path, [Map<String, dynamic>? queryParameters]) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return path;
    }
    final List<String> keys = queryParameters.keys.toList()..sort();
    final String query = keys
        .map((String k) => '$k=${queryParameters[k]}')
        .join('&');
    return '$path?$query';
  }

  Object? _cachedGet(String key) {
    final _CachedGetEntry? entry = _getCache[key];
    if (entry == null) {
      return null;
    }
    if (!entry.expiresAt.isAfter(DateTime.now())) {
      _getCache.remove(key);
      return null;
    }
    return entry.payload;
  }

  void _cachePut(String key, Object? payload) {
    _pruneExpired();
    _getCache[key] = _CachedGetEntry(
      payload: payload,
      expiresAt: DateTime.now().add(getCacheTtl),
    );
  }

  /// Drops expired entries so the map only ever holds live responses.
  void _pruneExpired() {
    final DateTime now = DateTime.now();
    _getCache.removeWhere(
      (String _, _CachedGetEntry entry) => !entry.expiresAt.isAfter(now),
    );
  }

  static List<Map<String, dynamic>> _expectObjectList(Object? data) {
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

  Map<String, dynamic> _expectObject(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ApiClientException('Expected JSON object response.');
  }
}

class _CachedGetEntry {
  const _CachedGetEntry({required this.payload, required this.expiresAt});

  final Object? payload;
  final DateTime expiresAt;
}

class ApiClientException implements Exception {
  const ApiClientException(this.message);

  final String message;
}
