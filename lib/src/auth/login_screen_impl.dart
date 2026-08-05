part of 'login_screen.dart';

/// UI texts and validation rules for the login screen.
///
/// Every string rendered by [LoginScreen] comes from here — the package holds
/// zero hardcoded text. Validators live alongside their messages so both stay
/// app-localizable.
abstract class LoginStrings {
  String get appBarTitle;
  String get subtitle;
  String get description;
  String get emailLabel;
  String get passwordLabel;
  String get submitLabel;
  String get googleSignInLabel;
  String get fillDemoLabel;
  String get demoEmail;
  String get demoPassword;

  /// Label of the opt-in registration button (see [LoginScreen.onRegisterTap]).
  String get registerLabel => 'Create an account';

  /// Returns an error message for an invalid email, or `null` when valid.
  m.FormFieldValidator<String> get emailValidator;

  /// Returns an error message for an invalid password, or `null` when valid.
  m.FormFieldValidator<String> get passwordValidator;
}

/// Reactive data the screen renders: loading, error and authenticated state.
///
/// Implementations bridge the app's state management (e.g. a bloc stream) into
/// these plain [m.ValueNotifier]s so the package stays framework-free.
abstract class LoginAsyncData {
  m.ValueNotifier<bool> get isLoading;
  m.ValueNotifier<String?> get errorMessage;

  /// Fires `true` once per successful authentication; the screen consumes the
  /// signal (resets it to `false`) and calls [LoginServiceCallbacks.navigateForward].
  m.ValueNotifier<bool> get isAuthenticated;

  void dispose();
}

/// Behavioural contract: what happens on submit and after authentication.
abstract class LoginServiceCallbacks {
  Future<void> login({required String email, required String password});

  /// Google sign-in flow. Only invoked when [LoginScreen.enableGoogleSignIn]
  /// is true; apps opting in override this (e.g. `google_sign_in` with the
  /// app's clientId).
  Future<void> googleSignIn() {
    throw UnsupportedError('Google sign-in is not enabled.');
  }

  /// Called once when the user becomes authenticated (see [LoginAsyncData.isAuthenticated]).
  /// The app owns navigation here (e.g. `context.goNamed(home)`).
  void navigateForward(m.BuildContext context);
}
