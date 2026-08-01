import 'package:google_sign_in/google_sign_in.dart';

import 'google_sign_in_service.dart';

/// [GoogleSignInService] backed by the `google_sign_in` plugin.
///
/// Client identifiers are app-owned and passed in the constructor; they are
/// never hardcoded in this package. The plugin requires `initialize()` to be
/// called exactly once before any other call, so this implementation memoizes
/// it.
class GoogleSignInServiceImpl implements GoogleSignInService {
  GoogleSignInServiceImpl({String? clientId, String? serverClientId})
    : _clientId = clientId,
      _serverClientId = serverClientId;

  /// The app's OAuth client ID.
  ///
  /// Only needed on platforms that require it (e.g. Android for the web
  /// client ID); null falls back to app-level configuration files.
  final String? _clientId;

  /// The backend server's OAuth client ID, used when the app's server must
  /// verify the ID token.
  final String? _serverClientId;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void>? _initialization;

  Future<void> _ensureInitialized() {
    return _initialization ??= _googleSignIn.initialize(
      clientId: _clientId,
      serverClientId: _serverClientId,
    );
  }

  @override
  Future<GoogleSignInResult?> signIn() async {
    await _ensureInitialized();
    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      return GoogleSignInResult(
        email: account.email,
        displayName: account.displayName,
        idToken: account.authentication.idToken,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
  }
}
