import 'package:flutter/material.dart' as m;
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/commons.dart';

class _FakeStrings implements LoginStrings {
  @override
  String get appBarTitle => 'Test Login';
  @override
  String get subtitle => 'Sign in';
  @override
  String get description => 'Use the demo account to continue.';
  @override
  String get emailLabel => 'Email';
  @override
  String get passwordLabel => 'Password';
  @override
  String get submitLabel => 'Sign in';
  @override
  String get googleSignInLabel => 'Continue with Google';
  @override
  String get fillDemoLabel => 'Fill demo credentials';
  @override
  String get demoEmail => 'demo@test.dev';
  @override
  String get demoPassword => 'password123';
  @override
  m.FormFieldValidator<String> get emailValidator => (String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Enter a valid email';
    return null;
  };
  @override
  m.FormFieldValidator<String> get passwordValidator => (String? value) {
    if (value == null || value.length < 8) return 'Password too short';
    return null;
  };
}

class _FakeAsyncData implements LoginAsyncData {
  @override
  final m.ValueNotifier<bool> isLoading = m.ValueNotifier<bool>(false);
  @override
  final m.ValueNotifier<String?> errorMessage =
      m.ValueNotifier<String?>(null);
  @override
  final m.ValueNotifier<bool> isAuthenticated = m.ValueNotifier<bool>(false);
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    isLoading.dispose();
    errorMessage.dispose();
    isAuthenticated.dispose();
  }
}

class _FakeCallbacks implements LoginServiceCallbacks {
  String? submittedEmail;
  String? submittedPassword;
  int loginCalls = 0;
  int navigateCalls = 0;
  int googleSignInCalls = 0;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    submittedEmail = email;
    submittedPassword = password;
  }

  @override
  Future<void> googleSignIn() async {
    googleSignInCalls++;
  }

  @override
  void navigateForward(m.BuildContext context) {
    navigateCalls++;
  }
}

m.Widget _wrap({
  required LoginStrings strings,
  required LoginAsyncData asyncData,
  required LoginServiceCallbacks callbacks,
  bool enableGoogleSignIn = false,
}) {
  return m.MaterialApp(
    home: LoginScreen(
      displayTexts: strings,
      asyncData: asyncData,
      callbacks: callbacks,
      enableGoogleSignIn: enableGoogleSignIn,
    ),
  );
}

/// The submit button renders via `FilledButton.icon`, whose runtime type is a
/// private subclass — `widgetWithText(m.FilledButton, ...)` therefore misses
/// it. Match on the base type instead.
final Finder _submitButton = find.byWidgetPredicate(
  (m.Widget w) => w is m.FilledButton,
);

void main() {
  testWidgets('renders title, fields and action buttons', (
    WidgetTester tester,
  ) async {
    final _FakeAsyncData asyncData = _FakeAsyncData();
    await tester.pumpWidget(
      _wrap(
        strings: _FakeStrings(),
        asyncData: asyncData,
        callbacks: _FakeCallbacks(),
      ),
    );

    expect(find.text('Test Login'), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Fill demo credentials'), findsOneWidget);
  });

  testWidgets('submits the demo credentials by default', (
    WidgetTester tester,
  ) async {
    final _FakeCallbacks callbacks = _FakeCallbacks();
    await tester.pumpWidget(
      _wrap(
        strings: _FakeStrings(),
        asyncData: _FakeAsyncData(),
        callbacks: callbacks,
      ),
    );

    // Fields are pre-filled with demo credentials.
    await tester.tap(_submitButton);
    await tester.pumpAndSettle();

    expect(callbacks.loginCalls, 1);
    expect(callbacks.submittedEmail, 'demo@test.dev');
    expect(callbacks.submittedPassword, 'password123');
  });

  testWidgets('loading state disables the submit button', (
    WidgetTester tester,
  ) async {
    final _FakeAsyncData asyncData = _FakeAsyncData();
    final _FakeCallbacks callbacks = _FakeCallbacks();
    await tester.pumpWidget(
      _wrap(
        strings: _FakeStrings(),
        asyncData: asyncData,
        callbacks: callbacks,
      ),
    );

    asyncData.isLoading.value = true;
    await tester.pump();

    final m.FilledButton button = tester.widget<m.FilledButton>(
      _submitButton,
    );
    expect(button.onPressed, isNull);

    await tester.tap(_submitButton);
    await tester.pump();
    expect(callbacks.loginCalls, 0);
  });

  testWidgets('renders the error message from async data', (
    WidgetTester tester,
  ) async {
    final _FakeAsyncData asyncData = _FakeAsyncData();
    await tester.pumpWidget(
      _wrap(
        strings: _FakeStrings(),
        asyncData: asyncData,
        callbacks: _FakeCallbacks(),
      ),
    );

    asyncData.errorMessage.value = 'Invalid credentials';
    await tester.pump();

    expect(find.text('Invalid credentials'), findsOneWidget);
  });

  testWidgets('navigates forward once when authenticated fires', (
    WidgetTester tester,
  ) async {
    final _FakeAsyncData asyncData = _FakeAsyncData();
    final _FakeCallbacks callbacks = _FakeCallbacks();
    await tester.pumpWidget(
      _wrap(
        strings: _FakeStrings(),
        asyncData: asyncData,
        callbacks: callbacks,
      ),
    );

    asyncData.isAuthenticated.value = true;
    await tester.pump();

    expect(callbacks.navigateCalls, 1);
    // The signal is consumed — a second frame does not re-navigate.
    await tester.pump();
    expect(callbacks.navigateCalls, 1);
  });

  testWidgets('google sign-in button is hidden by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        strings: _FakeStrings(),
        asyncData: _FakeAsyncData(),
        callbacks: _FakeCallbacks(),
      ),
    );

    expect(find.text('Continue with Google'), findsNothing);
  });

  testWidgets('google sign-in button calls googleSignIn when enabled', (
    WidgetTester tester,
  ) async {
    final _FakeCallbacks callbacks = _FakeCallbacks();
    await tester.pumpWidget(
      _wrap(
        strings: _FakeStrings(),
        asyncData: _FakeAsyncData(),
        callbacks: callbacks,
        enableGoogleSignIn: true,
      ),
    );

    expect(find.text('Continue with Google'), findsOneWidget);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(callbacks.googleSignInCalls, 1);
  });

  testWidgets('validators reject invalid input without calling login', (
    WidgetTester tester,
  ) async {
    final _FakeCallbacks callbacks = _FakeCallbacks();
    await tester.pumpWidget(
      _wrap(
        strings: _FakeStrings(),
        asyncData: _FakeAsyncData(),
        callbacks: callbacks,
      ),
    );

    await tester.enterText(find.widgetWithText(m.TextFormField, 'Email'), 'x');
    await tester.enterText(
      find.widgetWithText(m.TextFormField, 'Password'),
      'short',
    );
    await tester.tap(_submitButton);
    await tester.pumpAndSettle();

    expect(callbacks.loginCalls, 0);
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Password too short'), findsOneWidget);
  });
}
