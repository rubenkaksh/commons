import 'package:flutter/foundation.dart';

/// Abstraction over Google Sign-In so apps can swap or fake the plugin.
///
/// Apps opt in per-app: they construct the plugin-backed
/// [GoogleSignInServiceImpl] with their own client identifiers and wire it
/// into their auth flow. This interface never references the plugin, keeping
/// the dependency confined to the implementation.
abstract class GoogleSignInService {
  /// Starts the Google sign-in flow.
  ///
  /// Returns the signed-in account, or `null` when the user cancels the flow.
  /// Other failures are rethrown.
  Future<GoogleSignInResult?> signIn();

  /// Signs out the currently signed-in Google account, if any.
  Future<void> signOut();
}

/// Details of a successful Google sign-in.
@immutable
class GoogleSignInResult {
  const GoogleSignInResult({
    required this.email,
    this.displayName,
    this.idToken,
  });

  /// The user's email address.
  final String email;

  /// The user's display name, when the account provides one.
  final String? displayName;

  /// An ID token that can be verified by the app's backend.
  ///
  /// Tokens expire; treat this as a snapshot taken at sign-in time.
  final String? idToken;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GoogleSignInResult &&
        other.email == email &&
        other.displayName == displayName &&
        other.idToken == idToken;
  }

  @override
  int get hashCode => Object.hash(email, displayName, idToken);
}
