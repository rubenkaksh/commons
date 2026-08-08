/// Typed application exceptions for network/API failures.
///
/// [DioApiClient] converts raw [DioException]s into these at the client
/// boundary via [DioApiClient.mapDioException], so every service gets a
/// user-facing message for free and cubits can distinguish failure classes
/// (offline vs timeout vs server vs client) instead of discarding the error.
///
/// The hierarchy is closed ([sealed]) — new failure classes are added in
/// this file, never by consumers.
library;

/// Base class for all typed network failures.
///
/// [message] is safe to surface directly in the UI.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// User-facing message.
  final String message;

  @override
  String toString() => message;
}

/// The server rejected the request with an HTTP 4xx status — the request was
/// bad, not allowed, or otherwise the caller's fault. Prefers the server's
/// own `message` field when the error body carries one.
class AppClientException extends AppException {
  const AppClientException(super.message, {this.statusCode});

  final int? statusCode;
}

/// The server failed with an HTTP 5xx status — retrying later may help.
class AppServerException extends AppException {
  const AppServerException(super.message, {this.statusCode});

  final int? statusCode;
}

/// The request timed out (connect/send/receive).
class AppTimeoutException extends AppException {
  const AppTimeoutException(super.message);
}

/// The device appears to be offline (connection refused / no network).
class AppOfflineException extends AppException {
  const AppOfflineException(super.message);
}

/// Any other failure (cancelled request, malformed response, unknown error).
class AppUnexpectedException extends AppException {
  const AppUnexpectedException(super.message);
}
