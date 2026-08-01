import 'package:commons/commons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    hide GoogleSignInException, GoogleSignInExceptionCode;

/// Test double for the platform plugin; everything is available through the
/// `google_sign_in` barrel export.
class _FakeGoogleSignInPlatform extends GoogleSignInPlatform {
  GoogleSignInUserData? user;
  Object? authError;
  InitParameters? lastInitParams;
  int initCalls = 0;
  int signOutCalls = 0;

  @override
  Future<void> init(InitParameters params) async {
    initCalls++;
    lastInitParams = params;
  }

  @override
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) async => null;

  @override
  bool supportsAuthenticate() => true;

  @override
  Future<AuthenticationResults> authenticate(
    AuthenticateParameters params,
  ) async {
    final Object? error = authError;
    if (error != null) {
      throw error;
    }
    final GoogleSignInUserData? data = user;
    if (data == null) {
      throw StateError('No fake user configured.');
    }
    return AuthenticationResults(
      user: data,
      authenticationTokens: const AuthenticationTokenData(idToken: 'token-1'),
    );
  }

  @override
  bool authorizationRequiresUserInteraction() => true;

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) async => null;

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) async => null;

  @override
  Future<void> signOut(SignOutParams params) async {
    signOutCalls++;
  }

  @override
  Future<void> disconnect(DisconnectParams params) async {}
}

void main() {
  late _FakeGoogleSignInPlatform fakePlatform;
  late GoogleSignInServiceImpl service;

  setUp(() {
    fakePlatform = _FakeGoogleSignInPlatform();
    GoogleSignInPlatform.instance = fakePlatform;
    service = GoogleSignInServiceImpl(
      clientId: 'app-client-id',
      serverClientId: 'server-client-id',
    );
  });

  test('signIn returns account details on success', () async {
    fakePlatform.user = const GoogleSignInUserData(
      id: 'google-id-1',
      email: 'ada@example.com',
      displayName: 'Ada Lovelace',
    );

    final GoogleSignInResult? result = await service.signIn();

    expect(result?.email, 'ada@example.com');
    expect(result?.displayName, 'Ada Lovelace');
    expect(result?.idToken, 'token-1');
  });

  test('signIn returns null when the user cancels', () async {
    fakePlatform.authError = const GoogleSignInException(
      code: GoogleSignInExceptionCode.canceled,
    );

    final GoogleSignInResult? result = await service.signIn();

    expect(result, isNull);
  });

  test('signIn rethrows other GoogleSignInException codes', () async {
    fakePlatform.authError = const GoogleSignInException(
      code: GoogleSignInExceptionCode.clientConfigurationError,
    );

    expect(
      service.signIn(),
      throwsA(isA<GoogleSignInException>()),
    );
  });

  test('initialize is called exactly once with the app client ids', () async {
    fakePlatform.user = const GoogleSignInUserData(
      id: 'google-id-1',
      email: 'ada@example.com',
    );

    await service.signIn();
    await service.signIn();
    await service.signIn();

    expect(fakePlatform.initCalls, 1);
    expect(fakePlatform.lastInitParams?.clientId, 'app-client-id');
    expect(fakePlatform.lastInitParams?.serverClientId, 'server-client-id');
  });

  test('signOut delegates to the platform', () async {
    await service.signOut();

    expect(fakePlatform.signOutCalls, 1);
  });
}
